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
#if os(iOS)
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
#else
        NavigationView {
            List {
                NavigationLink(destination: MovieView()) {
                    Label("Movies", systemImage: "film")
                }
                .tag(MovieView.tag)
                NavigationLink(destination: SeriesView()) {
                    Label("TV", systemImage: "play.tv")
                }
                .tag(SeriesView.tag)
                NavigationLink(destination: WatchlistView()) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                .tag(WatchlistView.tag)
                NavigationLink(destination: SearchView()) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(SearchView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Story")
            MovieView()
        }
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
