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
    /// - Parameters:
    ///   - query: The search query (article title or extracted key terms).
    ///   - reviewPublisherSiteFilter: Optional domain to restrict results to a specific
    ///     fact-checking publisher (e.g. "boomlive.in"). Nil returns results from all publishers.
    ///   - languageCode: BCP-47 language code for the claim reviews (default "en").
    static func factCheck(
        query: String,
        reviewPublisherSiteFilter: String? = nil,
        languageCode: String = "en"
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host   = "factchecktools.googleapis.com"
        components.path   = "/v1alpha1/claims:search"

        var items: [URLQueryItem] = [
            URLQueryItem(name: "query",        value: query),
            URLQueryItem(name: "key",          value: APIKeys.googleFactCheck),
            URLQueryItem(name: "languageCode", value: languageCode)
        ]
        if let site = reviewPublisherSiteFilter {
            items.append(URLQueryItem(name: "reviewPublisherSiteFilter", value: site))
        }
        components.queryItems = items
        return components.url
    }
}
