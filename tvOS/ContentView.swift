//
//  ContentView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                WatchlistView()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
