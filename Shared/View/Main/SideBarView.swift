//
//  SideBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct SideBarView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Screens.home) {
                    Label("Home", systemImage: "house")
                }
                .tag(HomeView.tag)
                NavigationLink(value: Screens.explore) {
                    Label("Explore", systemImage: "film")
                }
                .tag(DiscoverView.tag)
                NavigationLink(value: Screens.watchlist) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                .tag(WatchlistView.tag)
                NavigationLink(value: Screens.search) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(SearchView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Cronica")
        } detail: {
            switch selectedView {
            case .search: SearchView()
            case .watchlist: WatchlistView()
            case .explore: DiscoverView()
            default: HomeView()
            }
        }
        .navigationDestination(for: Screens.self) { screens in
            switch screens {
            case .search: SearchView()
            case .watchlist: WatchlistView()
            case .explore: DiscoverView()
            default: HomeView()
            }
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}

