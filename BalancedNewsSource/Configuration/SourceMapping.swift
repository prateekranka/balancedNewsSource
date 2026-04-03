import Foundation

struct SourceMapping {

    // MARK: - Master source list

    static let sources: [NewsSource] = [
        // Left-Wing
        NewsSource(id: "cnn",                    name: "CNN",                    leaning: .left),
        NewsSource(id: "msnbc",                  name: "MSNBC",                  leaning: .left),
        NewsSource(id: "the-huffington-post",    name: "HuffPost",               leaning: .left),
        NewsSource(id: "buzzfeed-news",          name: "BuzzFeed News",          leaning: .left),
        NewsSource(id: "vice-news",              name: "Vice News",              leaning: .left),

        // Centrist
        NewsSource(id: "associated-press",       name: "Associated Press",       leaning: .center),
        NewsSource(id: "reuters",                name: "Reuters",                leaning: .center),
        NewsSource(id: "bbc-news",               name: "BBC News",               leaning: .center),
        NewsSource(id: "the-wall-street-journal",name: "The Wall Street Journal",leaning: .center),
        NewsSource(id: "abc-news",               name: "ABC News",               leaning: .center),

        // Right-Wing
        NewsSource(id: "fox-news",               name: "Fox News",               leaning: .right),
        NewsSource(id: "breitbart-news",         name: "Breitbart News",         leaning: .right),
        NewsSource(id: "the-washington-times",   name: "The Washington Times",   leaning: .right),
        NewsSource(id: "national-review",        name: "National Review",        leaning: .right),
        NewsSource(id: "new-york-post",          name: "New York Post",          leaning: .right)
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
