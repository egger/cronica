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
    @StateObject private var settings: SettingsStore
    @StateObject private var coordinator: Coordinator
    init() {
        _settings = StateObject(wrappedValue: SettingsStore())
        _coordinator = StateObject(wrappedValue: Coordinator())
    }
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
        .onChange(of: selectedView) { selected in
            if coordinator.selectedTab == nil {
                coordinator.selectedTab = selected
            } else {
                if coordinator.selectedTab == selected {
                    coordinator.goToHome()
                }
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Screens?
    
    func goToHome() {
        path.removeLast(path.count)
    }
}
