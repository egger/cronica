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
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            WatchlistView()
                .tag(WatchlistView.tag)
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("Watchlist")
                }
            EmptyView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            EmptyView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
