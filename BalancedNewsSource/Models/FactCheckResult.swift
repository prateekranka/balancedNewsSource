import Foundation

// MARK: - Top-level response wrapper

struct FactCheckResponse: Codable {
    let claims: [FactCheckClaim]?
}

// MARK: - Claim

struct FactCheckClaim: Codable {
    let text: String?
    let claimant: String?
    let claimReview: [ClaimReview]?
}

// MARK: - Review

struct ClaimReview: Codable {
    let textualRating: String?
    let publisher: ClaimPublisher?
    let url: String?
}

// MARK: - Publisher

struct ClaimPublisher: Codable {
    let name: String?
}
