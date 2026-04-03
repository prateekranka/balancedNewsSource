import Foundation

enum Endpoint {

    // MARK: - News API

    /// Builds a URL for the NewsAPI top-headlines endpoint filtered to the given sources.
    static func topHeadlines(sources: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host   = "newsapi.org"
        components.path   = "/v2/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "sources", value: sources),
            URLQueryItem(name: "apiKey",  value: APIKeys.newsAPI)
        ]
        return components.url
    }

    // MARK: - Google Fact Check Tools API

    /// Builds a URL for the Google Fact Check Tools claims search endpoint.
    static func factCheck(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host   = "factchecktools.googleapis.com"
        components.path   = "/v1alpha1/claims:search"
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key",   value: APIKeys.googleFactCheck)
        ]
        return components.url
    }
}
