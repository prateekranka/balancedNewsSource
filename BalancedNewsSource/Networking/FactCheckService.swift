import Foundation

final class FactCheckService {

    // MARK: - Constants

    /// Words in a textualRating that indicate a claim has been verified as true.
    private static let positiveRatingTokens: Set<String> = [
        "true", "correct", "accurate", "mostly true"
    ]

    /// IFCN-certified Indian fact-checking publishers tried before the general search.
    /// Ordered by coverage of English-language Indian news.
    static let indianFactCheckers: [String] = [
        "boomlive.in",
        "altnews.in",
        "factchecker.in",
        "vishvasnews.com",
        "newschecker.in"
    ]

    /// Common English stopwords and news-headline filler stripped before querying.
    static let stopWords: Set<String> = [
        "a", "an", "the", "in", "of", "for", "to", "at", "by", "on", "as",
        "is", "are", "was", "were", "be", "been", "has", "have", "had",
        "it", "its", "this", "that", "and", "or", "but", "not", "with",
        "from", "into", "over", "after", "across", "says", "said", "say",
        "amid", "up", "down", "out", "off", "than", "then", "when", "where",
        "who", "which", "what", "how", "about", "jolts", "felt", "amid",
        "slams", "hits", "marks", "calls", "urges", "warns", "claims"
    ]

    // MARK: - Public API

    /// Best-effort fact-check of the supplied article.
    /// Strategy:
    ///   1. Build a focused query by stripping stopwords from the title.
    ///   2. Fire all Indian fact-checker requests **in parallel**; return the first hit.
    ///   3. Fall back to a general (unfiltered) search with the focused query.
    ///   4. If still nothing, retry the general search with the original full title.
    /// Never throws — returns `.noClaimsFound` on any failure.
    func checkArticle(_ article: Article) async -> Article.FactCheckStatus {
        let focusedQuery = Self.extractQuery(from: article.title)

        // Pass 1 – All Indian fact-checkers fired in parallel; first result wins.
        if let status = await firstIndianResult(for: focusedQuery) {
            return status
        }

        // Pass 2 – General search with focused query.
        if let url = Endpoint.factCheck(query: focusedQuery),
           let status = await fetchStatus(from: url) {
            return status
        }

        // Pass 3 – General search with original full title (safety net).
        if focusedQuery != article.title.lowercased(),
           let url = Endpoint.factCheck(query: article.title),
           let status = await fetchStatus(from: url) {
            return status
        }

        return .noClaimsFound
    }

    // MARK: - Query Extraction

    /// Strips stopwords and punctuation from a headline and returns the top key terms.
    /// Keeping 6 meaningful words gives the API enough signal without over-constraining.
    ///
    /// Examples:
    ///   "Earthquake jolts J&K, tremors felt across North India"
    ///     → "earthquake j&k tremors north india"
    ///   "PM Modi says economy growing at fastest pace"
    ///     → "pm modi economy growing fastest pace"
    static func extractQuery(from title: String) -> String {
        title
            .components(separatedBy: .whitespacesAndNewlines)
            .map { word -> String in
                // Strip leading/trailing punctuation but keep internal characters like & and '
                word.trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.symbols).subtracting(Self.internalPunctuation))
                    .lowercased()
            }
            .filter { !$0.isEmpty && $0.count > 1 && !stopWords.contains($0) }
            .prefix(6)
            .joined(separator: " ")
    }

    /// Characters that are meaningful inside a word and should not be stripped (e.g. & in J&K).
    private static let internalPunctuation: CharacterSet = {
        var cs = CharacterSet()
        cs.insert(charactersIn: "&'")
        return cs
    }()

    // MARK: - Private Helpers

    /// Fires one request per Indian fact-checker site in parallel and returns the first
    /// non-nil result. Cancels the remaining tasks as soon as one succeeds.
    private func firstIndianResult(for query: String) async -> Article.FactCheckStatus? {
        let urls = Self.indianFactCheckers.compactMap {
            Endpoint.factCheck(query: query, reviewPublisherSiteFilter: $0)
        }
        guard !urls.isEmpty else { return nil }

        return await withTaskGroup(of: Article.FactCheckStatus?.self) { group in
            for url in urls {
                group.addTask { await self.fetchStatus(from: url) }
            }
            for await result in group {
                if let status = result {
                    group.cancelAll()
                    return status
                }
            }
            return nil
        }
    }

    /// Fetches and decodes a fact-check response, then maps it to a `FactCheckStatus`.
    /// Returns `nil` when the network call fails, decoding fails, or no claims are found
    /// (so callers can continue to the next pass).
    private func fetchStatus(from url: URL) async -> Article.FactCheckStatus? {
        guard
            let (data, _) = try? await URLSession.shared.data(from: url),
            let response  = try? JSONDecoder().decode(FactCheckResponse.self, from: data),
            let claims    = response.claims,
            !claims.isEmpty
        else { return nil }

        for claim in claims {
            guard let review = claim.claimReview.first else { continue }
            let rating     = review.textualRating
            let lowercased = rating.lowercased()
            let isPositive = Self.positiveRatingTokens.contains(where: { lowercased.contains($0) })
            return isPositive ? .verified : .disputed(rating)
        }

        // Claims returned but none carried a claimReview — treat as not found so the
        // caller can try the next pass.
        return nil
    }
}
