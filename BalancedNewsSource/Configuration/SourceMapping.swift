import Foundation

struct SourceMapping {

    // MARK: - Master source list

    static let sources: [NewsSource] = [
        // Left-Leaning
        NewsSource(id: "the-hindu",       name: "The Hindu",        domain: "thehindu.com",        leaning: .left),
        NewsSource(id: "ndtv",            name: "NDTV",             domain: "ndtv.com",            leaning: .left),
        NewsSource(id: "the-wire",        name: "The Wire",         domain: "thewire.in",          leaning: .left),
        NewsSource(id: "scroll-in",       name: "Scroll.in",        domain: "scroll.in",           leaning: .left),
        NewsSource(id: "indian-express",  name: "Indian Express",   domain: "indianexpress.com",   leaning: .left),

        // Centrist
        NewsSource(id: "times-of-india",  name: "The Times of India", domain: "timesofindia.indiatimes.com", leaning: .center),
        NewsSource(id: "hindustan-times", name: "Hindustan Times",  domain: "hindustantimes.com",  leaning: .center),
        NewsSource(id: "economic-times",  name: "The Economic Times", domain: "economictimes.indiatimes.com", leaning: .center),
        NewsSource(id: "mint",            name: "Mint",             domain: "livemint.com",        leaning: .center),
        NewsSource(id: "firstpost",       name: "Firstpost",        domain: "firstpost.com",       leaning: .center),

        // Right-Leaning
        NewsSource(id: "republic-world",  name: "Republic World",   domain: "republicworld.com",   leaning: .right),
        NewsSource(id: "opindia",         name: "OpIndia",          domain: "opindia.com",         leaning: .right),
        NewsSource(id: "swarajya",        name: "Swarajya",         domain: "swarajyamag.com",     leaning: .right),
        NewsSource(id: "zee-news",        name: "Zee News",         domain: "zeenews.india.com",   leaning: .right),
        NewsSource(id: "news18",          name: "News18",           domain: "news18.com",          leaning: .right)
    ]

    // MARK: - Helpers

    /// Returns the domains that belong to the given political leaning.
    static func domains(for leaning: PoliticalLeaning) -> [String] {
        sources
            .filter { $0.leaning == leaning }
            .map { $0.domain }
    }

    /// Returns a comma-separated string of domains for the given leaning,
    /// ready to be passed directly as the `domains` query parameter.
    static func commaSeparatedDomains(for leaning: PoliticalLeaning) -> String {
        domains(for: leaning).joined(separator: ",")
    }
}
