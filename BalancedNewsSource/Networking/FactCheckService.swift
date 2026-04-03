import Foundation

final class FactCheckService {

    // MARK: - Private Helpers

    /// Words in a textualRating that indicate a claim has been verified as true.
    private static let positiveRatingTokens: Set<String> = [
        "true", "correct", "accurate", "mostly true"
    ]

    // MARK: - Public API

    /// Best-effort fact-check of the supplied article.
    /// Never throws — returns `.noClaimsFound` on any failure.
    func checkArticle(_ article: Article) async -> Article.FactCheckStatus {
        guard let url = Endpoint.factCheck(query: article.title) else {
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
            guard let review = claim.claimReview.first else { continue }

            let rating = review.textualRating
            let lowercased = rating.lowercased()

            let isPositive = Self.positiveRatingTokens.contains(where: { lowercased.contains($0) })
            return isPositive ? .verified : .disputed(rating)
        }

        // Claims exist but none carry a claimReview.
        return .noClaimsFound
    }
}
