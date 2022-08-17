//
//  TabBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI

/// A TabBar for switching views, only used on iPhone.
struct TabBarView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView()
                .tag(HomeView.tag)
                .tabItem { Label("Home", systemImage: "house") }
            DiscoverView()
                .tag(DiscoverView.tag)
                .tabItem { Label("Explore", systemImage: "film") }
            WatchlistView()
                .tag(WatchlistView.tag)
                .tabItem {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
            SearchView()
                .tag(SearchView.tag)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
