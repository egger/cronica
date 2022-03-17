//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView()
                .tag(HomeView.tag)
                .tabItem { Label("Home", systemImage: "house") }
            WatchlistView()
                .tag(WatchlistView.tag)
                .tabItem { Label("Watchlist", systemImage: "square.stack.fill") }
            SearchView()
                .tag(SearchView.tag)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
