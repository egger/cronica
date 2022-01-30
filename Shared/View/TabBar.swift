//
//  TabBar.swift
//  Story
//
//  Created by Alexandre Madeira on 30/01/22.
//

import SwiftUI

struct TabBar: View {
    @SceneStorage("selectedView") var selectedView: String?
    var body: some View {
        TabView(selection: $selectedView) {
            MovieView()
                .tag(MovieView.tag)
                .tabItem {
                    Image(systemName: "film")
                    Text("Movies")
                }
            SeriesView()
                .tabItem {
                    Image(systemName: "play.tv")
                    Text("TV")
                }
            WatchlistView()
                .tag(WatchlistView.tag)
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("Watchlist")
                }
            SearchView()
                .tag(SearchView.tag)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        }
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
