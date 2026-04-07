import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FlowDeckView()
                .tabItem {
                    Label("Flow Deck", systemImage: "rectangle.stack")
                }

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
