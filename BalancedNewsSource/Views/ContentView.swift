import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ForEach(PoliticalLeaning.allCases) { leaning in
                NewsListView(viewModel: NewsListViewModel(leaning: leaning))
                    .tabItem {
                        Label(leaning.rawValue, systemImage: leaning.tabIcon)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
