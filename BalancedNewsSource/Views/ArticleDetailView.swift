import SwiftUI

struct ArticleDetailView: View {

    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroImage
                Group {
                    Text(article.title)
                        .font(.title)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text(article.sourceName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(article.publishedAt.relativeFormatted)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        factCheckIcon
                    }

                    if let description = article.description {
                        Text(description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Link(destination: article.url) {
                        Text("Read Full Article")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero Image

    @ViewBuilder
    private var heroImage: some View {
        if let imageURL = article.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Color(.systemGray5)
                @unknown default:
                    Color(.systemGray5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()
        }
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
