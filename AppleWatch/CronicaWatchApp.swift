//
//  CronicaWatchApp.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 02/08/22.
//

import SwiftUI

@main
struct CronicaWatchApp: App {
    var persistence = PersistenceController.shared
    @AppStorage("selectedView") var selectedView: Screens?
    init() {
        CronicaTelemetry.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedView) {
                TrendingView()
                    .tag(TrendingView.tag)
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tabItem {
                        Label("Trending", systemImage: "popcorn")
                            .labelStyle(.titleOnly)
                    }
                WatchlistView()
                    .tag(WatchlistView.tag)
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tabItem {
                        Label("Watchlist", systemImage: "square.stack")
                            .labelStyle(.titleOnly)
                    }
                UpNextListView()
                    .tag(UpNextListView.tag)
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tabItem {
                        Label("Up Next", systemImage: "tv")
                            .labelStyle(.titleOnly)
                    }
                UpcomingListView()
                    .tag(UpcomingListView.tag)
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tabItem {
                        Label("Upcoming", systemImage: "calendar")
                            .labelStyle(.titleOnly)
                    }
                
                SearchView()
                    .tag(SearchView.tag)
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                            .labelStyle(.titleOnly)
                    }
                
                SettingsView()
                    .tag(SettingsView.tag)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.titleOnly)
                    }
            }
            
        }
    }
}
