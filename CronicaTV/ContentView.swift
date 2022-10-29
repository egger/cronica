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
                    }
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "square.stack.fill")
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
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
