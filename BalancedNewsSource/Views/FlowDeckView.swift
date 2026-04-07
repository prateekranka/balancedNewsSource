import SwiftUI

/// A swipeable card-deck view that presents a balanced mix of articles
/// from left, center, and right-leaning sources. Swipe right to open
/// an article; swipe left to skip it.
struct FlowDeckView: View {

    @StateObject private var viewModel = FlowDeckViewModel()
    @State private var dragOffset: CGSize = .zero
    @State private var selectedArticle: Article? = nil

    // How far the user must drag before the card is dismissed.
    private let swipeThreshold: CGFloat = 120

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.cards.isEmpty {
                    emptyView
                } else {
                    cardStack
                }
            }
            .navigationTitle("Flow Deck")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            .task { await viewModel.loadDeck() }
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            // Render the bottom two cards first (no interaction), then the top.
            ForEach(visibleCards.reversed()) { article in
                let stackIndex = stackIndex(for: article)
                let isTop = stackIndex == 0

                FlowDeckCardView(
                    article: article,
                    dragOffset: isTop ? dragOffset : .zero,
                    isTop: isTop
                )
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight(for: stackIndex))
                .scaleEffect(cardScale(for: stackIndex))
                .offset(
                    x: isTop ? dragOffset.width : 0,
                    y: isTop
                        ? dragOffset.height * 0.3
                        : cardVerticalOffset(for: stackIndex)
                )
                .rotationEffect(isTop ? cardRotation : .zero)
                .zIndex(Double(visibleCards.count - stackIndex))
                .gesture(isTop ? swipeGesture : nil)
                .animation(.interactiveSpring(), value: dragOffset)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }

    // MARK: - Visible Card Subset

    private var visibleCards: [Article] {
        Array(viewModel.cards.prefix(3))
    }

    private func stackIndex(for article: Article) -> Int {
        visibleCards.firstIndex(where: { $0.id == article.id }) ?? 0
    }

    // MARK: - Stack Geometry

    private func cardHeight(for index: Int) -> CGFloat {
        let base: CGFloat = 520
        return base - CGFloat(index) * 20
    }

    private func cardScale(for index: Int) -> CGFloat {
        1.0 - CGFloat(index) * 0.04
    }

    private func cardVerticalOffset(for index: Int) -> CGFloat {
        CGFloat(index) * 12
    }

    private var cardRotation: Angle {
        .degrees(dragOffset.width / 20)
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                handleSwipeEnd(translation: value.translation)
            }
    }

    private func handleSwipeEnd(translation: CGSize) {
        let horizontalSwipe = abs(translation.width) > abs(translation.height)
        let swipedFarEnough = abs(translation.width) > swipeThreshold

        if horizontalSwipe && swipedFarEnough {
            let flyOffX: CGFloat = translation.width > 0 ? 600 : -600
            withAnimation(.easeOut(duration: 0.25)) {
                dragOffset = CGSize(width: flyOffX, height: translation.height)
            }
            if translation.width > 0 {
                // Swipe right → open article
                selectedArticle = viewModel.cards.first
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                dragOffset = .zero
                viewModel.dismissTopCard()
            }
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    // MARK: - Loading / Error / Empty Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Loading your balanced deck…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again") {
                Task { await viewModel.refreshDeck() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("You've read through the deck!")
                .font(.headline)
            Text("Pull to refresh for a fresh batch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Reload Deck") {
                Task { await viewModel.refreshDeck() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    FlowDeckView()
}
