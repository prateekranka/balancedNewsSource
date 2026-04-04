import Foundation

enum Endpoint {

    // MARK: - News API

    /// Builds a URL for the NewsAPI everything endpoint filtered to the given domains.
    static func everything(domains: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host   = "newsapi.org"
        components.path   = "/v2/everything"
        components.queryItems = [
            URLQueryItem(name: "domains",  value: domains),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "sortBy",   value: "publishedAt"),
            URLQueryItem(name: "pageSize", value: "20"),
            URLQueryItem(name: "apiKey",   value: APIKeys.newsAPI)
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
            URLQueryItem(name: "query",        value: query),
            URLQueryItem(name: "languageCode", value: "en"),
            URLQueryItem(name: "pageSize",     value: "5"),
            URLQueryItem(name: "key",          value: APIKeys.googleFactCheck)
        ]
        return components.url
    }
}
