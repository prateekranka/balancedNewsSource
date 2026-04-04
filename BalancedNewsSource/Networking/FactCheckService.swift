import Foundation

final class FactCheckService {

    // MARK: - Private Helpers

    /// Words in a textualRating that indicate a claim has been verified as true.
    private static let positiveRatingTokens: Set<String> = [
        "true", "correct", "accurate", "mostly true", "mostly correct",
        "partly true", "half true", "fact", "verified", "authentic"
    ]

    /// Words that clearly indicate a claim is false / disputed.
    private static let negativeRatingTokens: Set<String> = [
        "false", "fake", "misleading", "incorrect", "pants on fire",
        "mostly false", "partly false", "fabricated", "manipulated",
        "altered", "out of context", "unproven", "distorted"
    ]

    /// Common stop-words stripped from titles to build a shorter, more relevant
    /// search query for the Fact Check API.
    private static let stopWords: Set<String> = [
        "a", "an", "the", "is", "are", "was", "were", "be", "been",
        "being", "have", "has", "had", "do", "does", "did", "will",
        "would", "could", "should", "may", "might", "shall", "can",
        "to", "of", "in", "for", "on", "with", "at", "by", "from",
        "as", "into", "through", "during", "before", "after", "and",
        "but", "or", "nor", "not", "so", "yet", "both", "either",
        "neither", "each", "every", "all", "any", "few", "more",
        "most", "other", "some", "such", "no", "only", "own", "same",
        "than", "too", "very", "just", "about", "above", "also",
        "how", "what", "when", "where", "who", "whom", "why", "which",
        "that", "this", "these", "those", "its", "it", "he", "she",
        "his", "her", "they", "them", "their", "our", "we", "my",
        "your", "up", "out", "if", "over", "says", "said", "new",
        "like", "get", "got", "news", "report", "reports", "live",
        "update", "updates", "latest", "breaking", "watch", "here"
    ]

    // MARK: - Public API

    /// Best-effort fact-check of the supplied article.
    /// Never throws — returns `.noClaimsFound` on any failure.
    func checkArticle(_ article: Article) async -> Article.FactCheckStatus {
        let query = Self.buildQuery(from: article.title)

        guard !query.isEmpty,
              let url = Endpoint.factCheck(query: query) else {
            return .noClaimsFound
        }

        let data: Data
        do {
            let (responseData, _) = try await URLSession.shared.data(from: url)
            data = responseData
        } catch {
            return .noClaimsFound
        }

        let response: FactCheckResponse
        do {
            let decoder = JSONDecoder()
            response = try decoder.decode(FactCheckResponse.self, from: data)
        } catch {
            return .noClaimsFound
        }

        guard let claims = response.claims, !claims.isEmpty else {
            return .noClaimsFound
        }

        // Collect the first available claimReview across all claims.
        for claim in claims {
            guard let reviews = claim.claimReview,
                  let review = reviews.first,
                  let rating = review.textualRating else { continue }

            let lowercased = rating.lowercased()

            let isPositive = Self.positiveRatingTokens.contains(where: { lowercased.contains($0) })
            if isPositive { return .verified }

            let isNegative = Self.negativeRatingTokens.contains(where: { lowercased.contains($0) })
            if isNegative { return .disputed(rating) }

            // Rating exists but doesn't clearly match either list — treat as disputed.
            return .disputed(rating)
        }

        // Claims exist but none carry a claimReview.
        return .noClaimsFound
    }

    // MARK: - Query Building

    /// Extracts the most meaningful keywords from an article title so the
    /// Fact Check API has a better chance of matching indexed claims.
    /// Returns up to 8 keywords joined by spaces.
    private static func buildQuery(from title: String) -> String {
        // Strip punctuation and split into words.
        let cleaned = title.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: " ")

        let words = cleaned
            .lowercased()
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 2 && !stopWords.contains($0) }

        // Take the first 8 meaningful keywords.
        let keywords = Array(words.prefix(8))
        return keywords.joined(separator: " ")
    }
}
