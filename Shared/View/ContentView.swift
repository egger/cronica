//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    
    // MARK: - UI Elements
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            TabBarView()
        } else {
            SideBarView()
        }
#else
        SideBarView()
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
        ContentView().preferredColorScheme(.dark)
    }
}

struct SideBarView: View {
    @SceneStorage("selectedView") var selectedView: String?
    @ViewBuilder
    var body: some View {
        NavigationView {
            List(selection: $selectedView) {
                NavigationLink(destination: HomeView()) {
                    Label("Home", systemImage: "house")
                }.tag(HomeView.tag)
                NavigationLink(destination: WatchlistView()) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }.tag(WatchlistView.tag)
                NavigationLink(destination: SearchView()) {
                    Label("Search", systemImage: "magnifyingglass")
                }.tag(SearchView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Cronica")
            HomeView()
        }
        .navigationViewStyle(.columns)
    }
}

struct TabBarView: View {
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
