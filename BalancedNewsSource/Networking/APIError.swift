import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code): return "Server error (HTTP \(code))"
        case .decodingError(let error): return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .rateLimited: return "Rate limited. Please try again later."
        }
    }
}
