//
//  ContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVTabView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    var body: some View {
        NavigationStack {
            TabView {
                TVHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .labelStyle(.titleOnly)
                    }
                TVWatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "square.stack.fill")
                            .labelStyle(.titleOnly)
                    }
                TVSearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                            .labelStyle(.iconOnly)
                    }
                TVSettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.iconOnly)
                    }
            }
        }
    }
}
#endif
