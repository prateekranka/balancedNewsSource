import Foundation

@MainActor
final class NewsListViewModel: ObservableObject {

    // MARK: - Published State

    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Properties

    let leaning: PoliticalLeaning

    // MARK: - Private Services

    private let newsService: NewsAPIService
    private let factCheckService: FactCheckService

    // MARK: - Init

    init(
        leaning: PoliticalLeaning,
        newsService: NewsAPIService = .init(),
        factCheckService: FactCheckService = .init()
    ) {
        self.leaning = leaning
        self.newsService = newsService
        self.factCheckService = factCheckService
    }

    // MARK: - Public Actions

    /// Fetches articles for the configured leaning, then fact-checks each one
    /// concurrently (capped at 3 simultaneous requests).
    func loadArticles() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await newsService.fetchArticles(for: leaning)
            articles = fetched
            isLoading = false
            await runFactChecks()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            isLoading = false
        }
    }

    /// Clears existing articles then reloads — suitable for pull-to-refresh.
    func refreshArticles() async {
        articles = []
        await loadArticles()
    }

    // MARK: - Private Helpers

    private func runFactChecks() async {
        // Mark every article as .checking before spawning the task group.
        for index in articles.indices {
            articles[index].factCheckStatus = .checking
        }

        // Snapshot the articles we will check so index math stays stable.
        let snapshot = articles

        await withTaskGroup(of: (Int, Article.FactCheckStatus).self) { group in
            // Limit concurrency to 3 simultaneous fact-check requests.
            let maxConcurrent = 3
            var pendingIndex = 0

            // Seed the group with the first `maxConcurrent` tasks.
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

            // As each task finishes, update the UI and enqueue the next one.
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

    /// Safely updates the fact-check status for the article at `index`,
    /// matching by id in case the array was replaced during a refresh.
    private func updateStatus(_ status: Article.FactCheckStatus, at index: Int) {
        guard index < articles.count else { return }
        articles[index].factCheckStatus = status
    }
}
