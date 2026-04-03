import SwiftUI

struct ArticleRowView: View {

    let article: Article

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(article.sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    factCheckIcon
                }
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnail: some View {
        if let imageURL = article.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    placeholderThumbnail
                @unknown default:
                    placeholderThumbnail
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var placeholderThumbnail: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .overlay(
                Image(systemName: "newspaper")
                    .foregroundStyle(.tertiary)
            )
    }

    // MARK: - Fact-Check Icon

    @ViewBuilder
    private var factCheckIcon: some View {
        switch article.factCheckStatus {
        case .verified:
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
        case .disputed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        case .checking:
            ProgressView()
                .scaleEffect(0.7)
        case .unchecked, .noClaimsFound:
            EmptyView()
        }
    }
}
