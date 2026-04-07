import SwiftUI

/// A single card in the FlowDeck, displaying article image, title,
/// source, political leaning badge, and fact-check status.
struct FlowDeckCardView: View {

    let article: Article
    /// Drag offset passed in from the parent so multiple cards can
    /// participate in the parallax stack effect.
    var dragOffset: CGSize = .zero
    /// Whether this is the topmost (interactive) card.
    var isTop: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            heroImage
            overlay
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        .overlay(swipeHintOverlay, alignment: .top)
    }

    // MARK: - Hero Image

    @ViewBuilder
    private var heroImage: some View {
        if let imageURL = article.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderGradient
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        } else {
            placeholderGradient
        }
    }

    private var placeholderGradient: some View {
        LinearGradient(
            colors: [leaningColor.opacity(0.6), leaningColor.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Bottom Overlay

    private var overlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                leaningBadge
                Spacer()
                factCheckBadge
            }

            Text(article.title)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(article.sourceName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text(article.publishedAt.relativeFormatted)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Leaning Badge

    private var leaningBadge: some View {
        Text(article.sourceID.isEmpty ? "—" : leaningLabel)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(leaningColor.opacity(0.9))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var leaningLabel: String {
        let leftIDs = Set(SourceMapping.sourceIDs(for: .left))
        let rightIDs = Set(SourceMapping.sourceIDs(for: .right))
        if leftIDs.contains(article.sourceID)  { return "Left" }
        if rightIDs.contains(article.sourceID) { return "Right" }
        return "Center"
    }

    private var leaningColor: Color {
        let leftIDs = Set(SourceMapping.sourceIDs(for: .left))
        let rightIDs = Set(SourceMapping.sourceIDs(for: .right))
        if leftIDs.contains(article.sourceID)  { return .blue }
        if rightIDs.contains(article.sourceID) { return .red }
        return .purple
    }

    // MARK: - Fact-Check Badge

    @ViewBuilder
    private var factCheckBadge: some View {
        switch article.factCheckStatus {
        case .verified:
            Label("Verified", systemImage: "checkmark.seal.fill")
                .font(.caption2.bold())
                .foregroundStyle(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.45))
                .clipShape(Capsule())
        case .disputed(let reason):
            Label(reason.isEmpty ? "Disputed" : reason, systemImage: "exclamationmark.triangle.fill")
                .font(.caption2.bold())
                .foregroundStyle(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.45))
                .clipShape(Capsule())
                .lineLimit(1)
        case .checking:
            ProgressView()
                .scaleEffect(0.7)
                .padding(4)
                .background(.black.opacity(0.35))
                .clipShape(Circle())
        case .unchecked, .noClaimsFound:
            EmptyView()
        }
    }

    // MARK: - Swipe Hint Overlay (top card only)

    @ViewBuilder
    private var swipeHintOverlay: some View {
        if isTop {
            HStack {
                // Left swipe hint: skip
                Label("SKIP", systemImage: "xmark")
                    .font(.title3.bold())
                    .foregroundStyle(.red)
                    .padding(10)
                    .background(.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .rotationEffect(.degrees(-15))
                    .opacity(leftHintOpacity)
                    .padding(.leading, 20)
                    .padding(.top, 24)

                Spacer()

                // Right swipe hint: read
                Label("READ", systemImage: "book.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                    .padding(10)
                    .background(.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .rotationEffect(.degrees(15))
                    .opacity(rightHintOpacity)
                    .padding(.trailing, 20)
                    .padding(.top, 24)
            }
        }
    }

    private var leftHintOpacity: Double {
        max(0, min(1, -dragOffset.width / 80))
    }

    private var rightHintOpacity: Double {
        max(0, min(1, dragOffset.width / 80))
    }
}
