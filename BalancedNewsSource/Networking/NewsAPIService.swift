import Foundation

final class NewsAPIService {

    // MARK: - Private response wrapper

    private struct NewsAPIResponse: Decodable {
        let status: String
        let totalResults: Int
        let articles: [Article]
    }

    // MARK: - Public API

    /// Fetches articles for the given political leaning from Indian news sources.
    func fetchArticles(for leaning: PoliticalLeaning) async throws -> [Article] {
        let domains = SourceMapping.commaSeparatedDomains(for: leaning)

        guard let url = Endpoint.everything(domains: domains) else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                break
            case 429:
                throw APIError.rateLimited
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)
            return apiResponse.articles
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
