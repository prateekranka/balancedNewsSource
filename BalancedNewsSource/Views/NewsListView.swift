import SwiftUI

struct NewsListView: View {

    @StateObject var viewModel: NewsListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(viewModel.leaning.rawValue)
                .task { await viewModel.loadArticles() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.articles.isEmpty {
            loadingView
        } else if let message = viewModel.errorMessage, viewModel.articles.isEmpty {
            errorView(message: message)
        } else {
            articleList
        }
    }

    // MARK: - Sub-views

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading articles…")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry") {
                Task { await viewModel.loadArticles() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var articleList: some View {
        List(viewModel.articles) { article in
            NavigationLink(value: article) {
                ArticleRowView(article: article)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
        .refreshable {
            await viewModel.refreshArticles()
        }
    }
}
