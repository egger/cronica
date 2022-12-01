//
//  ContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .labelStyle(.titleOnly)
                    }
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "square.stack.fill")
                            .labelStyle(.titleOnly)
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                            .labelStyle(.iconOnly)
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.iconOnly)
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
