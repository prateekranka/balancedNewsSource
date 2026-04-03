import Foundation

struct Article: Identifiable, Codable, Hashable {

    // MARK: - Nested Types

    enum FactCheckStatus: Hashable {
        case unchecked
        case checking
        case verified
        case disputed(String)
        case noClaimsFound
    }

    // MARK: - Properties

    let id: UUID
    let title: String
    let description: String?
    let url: URL
    let imageURL: URL?
    let publishedAt: Date
    let sourceName: String
    let sourceID: String
    var factCheckStatus: FactCheckStatus

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case url
        case imageURL = "urlToImage"
        case publishedAt
        case source
    }

    private enum SourceCodingKeys: String, CodingKey {
        case id
        case name
    }

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title       = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        url         = try container.decode(URL.self, forKey: .url)
        imageURL    = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        publishedAt = try container.decode(Date.self, forKey: .publishedAt)

        let sourceContainer = try container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source)
        sourceName = try sourceContainer.decode(String.self, forKey: .name)
        sourceID   = try sourceContainer.decodeIfPresent(String.self, forKey: .id) ?? ""

        // Auto-generate a stable identity; NewsAPI does not supply one.
        id              = UUID()
        factCheckStatus = .unchecked
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title,       forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(url,         forKey: .url)
        try container.encodeIfPresent(imageURL,    forKey: .imageURL)
        try container.encode(publishedAt, forKey: .publishedAt)

        var sourceContainer = container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source)
        try sourceContainer.encode(sourceName, forKey: .name)
        try sourceContainer.encode(sourceID,   forKey: .id)

        // factCheckStatus is intentionally excluded from encoding.
    }

    // MARK: - Hashable

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
