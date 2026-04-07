import Foundation

/// Manages a balanced deck of articles from all three political leanings,
/// interleaved for ideological balance. Cards are consumed one at a time
/// as the user swipes through the deck.
@MainActor
final class FlowDeckViewModel: ObservableObject {

    // MARK: - Published State

    @Published var cards: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Services

    private let newsService: NewsAPIService
    private let factCheckService: FactCheckService

    // MARK: - Init

    init(
        newsService: NewsAPIService = .init(),
        factCheckService: FactCheckService = .init()
    ) {
        self.newsService = newsService
        self.factCheckService = factCheckService
    }

    // MARK: - Public Actions

    /// Loads articles from all three political leanings concurrently,
    /// then interleaves them for a balanced deck.
    func loadDeck() async {
        guard cards.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let leftArticles   = newsService.fetchArticles(for: .left)
            async let centerArticles = newsService.fetchArticles(for: .center)
            async let rightArticles  = newsService.fetchArticles(for: .right)

            let (left, center, right) = try await (leftArticles, centerArticles, rightArticles)
            cards = interleave(left, center, right)
            isLoading = false
            await runFactChecks()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            isLoading = false
        }
    }

    /// Reloads the deck from scratch.
    func refreshDeck() async {
        cards = []
        await loadDeck()
    }

    /// Removes the top card (index 0) after a swipe.
    func dismissTopCard() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()
    }

    // MARK: - Private Helpers

    /// Round-robin interleave: left, center, right, left, center, right, …
    private func interleave(
        _ left: [Article],
        _ center: [Article],
        _ right: [Article]
    ) -> [Article] {
        var result: [Article] = []
        let maxCount = max(left.count, center.count, right.count)
        for i in 0..<maxCount {
            if i < left.count   { result.append(left[i]) }
            if i < center.count { result.append(center[i]) }
            if i < right.count  { result.append(right[i]) }
        }
        return result
    }

    private func runFactChecks() async {
        for index in cards.indices {
            cards[index].factCheckStatus = .checking
        }

        let snapshot = cards

        await withTaskGroup(of: (Int, Article.FactCheckStatus).self) { group in
            let maxConcurrent = 3
            var pendingIndex = 0

            while pendingIndex < min(maxConcurrent, snapshot.count) {
                let index = pendingIndex
                let article = snapshot[index]
                group.addTask { [weak self] in
                    guard let self else { return (index, .noClaimsFound) }
                    let status = await self.factCheckService.checkArticle(article)
                    return (index, status)
                }
                pendingIndex += 1
            }

            for await (completedIndex, status) in group {
                updateStatus(status, at: completedIndex)

                if pendingIndex < snapshot.count {
                    let index = pendingIndex
                    let article = snapshot[index]
                    group.addTask { [weak self] in
                        guard let self else { return (index, .noClaimsFound) }
                        let status = await self.factCheckService.checkArticle(article)
                        return (index, status)
                    }
                    pendingIndex += 1
                }
            }
        }
    }

    private func updateStatus(_ status: Article.FactCheckStatus, at index: Int) {
        guard index < cards.count else { return }
        cards[index].factCheckStatus = status
    }
}
