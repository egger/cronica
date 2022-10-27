//
//  ContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    @StateObject var persistence = PersistenceController.shared
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            NavigationStack {
                WatchlistView()
            }
            .tabItem {
                Label("Watchlist", systemImage: "square.stack.fill")
            }
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
