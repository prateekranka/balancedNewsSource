import Foundation

struct SourceMapping {

    // MARK: - Master source list

    static let sources: [NewsSource] = [
        // Left-Wing (progressive / opposition-leaning Indian outlets)
        NewsSource(id: "the-hindu",              name: "The Hindu",              leaning: .left),
        NewsSource(id: "ndtv",                   name: "NDTV",                   leaning: .left),
        NewsSource(id: "the-wire",               name: "The Wire",               leaning: .left),
        NewsSource(id: "scroll-news",            name: "Scroll.in",              leaning: .left),
        NewsSource(id: "the-quint",              name: "The Quint",              leaning: .left),

        // Centrist (broadly neutral Indian outlets)
        NewsSource(id: "the-indian-express",     name: "The Indian Express",     leaning: .center),
        NewsSource(id: "hindustan-times",        name: "Hindustan Times",        leaning: .center),
        NewsSource(id: "the-times-of-india",     name: "The Times of India",     leaning: .center),
        NewsSource(id: "india-today",            name: "India Today",            leaning: .center),
        NewsSource(id: "bbc-news",               name: "BBC News",               leaning: .center),

        // Right-Wing (pro-establishment / nationalist-leaning Indian outlets)
        NewsSource(id: "news18",                 name: "News18",                 leaning: .right),
        NewsSource(id: "zee-news",               name: "Zee News",               leaning: .right),
        NewsSource(id: "republic-world",         name: "Republic World",         leaning: .right),
        NewsSource(id: "the-economic-times",     name: "The Economic Times",     leaning: .right),
        NewsSource(id: "wion",                   name: "WION",                   leaning: .right)
    ]

    // MARK: - Helpers

    /// Returns the NewsAPI source IDs that belong to the given political leaning.
    static func sourceIDs(for leaning: PoliticalLeaning) -> [String] {
        sources
            .filter { $0.leaning == leaning }
            .map { $0.id }
    }

    /// Returns a comma-separated string of NewsAPI source IDs for the given leaning,
    /// ready to be passed directly as the `sources` query parameter.
    static func commaSeparatedIDs(for leaning: PoliticalLeaning) -> String {
        sourceIDs(for: leaning).joined(separator: ",")
    }
}
