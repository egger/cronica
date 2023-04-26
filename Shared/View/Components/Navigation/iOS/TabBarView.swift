//
//  TabBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI

/// A TabBar for switching views, only used on iPhone.
struct TabBarView: View {
    @AppStorage("selectedView") var selectedView: Screens?
    @State private var showSettings = true
    var persistence = PersistenceController.shared
    var body: some View {
#if os(iOS)
        iOSBarView
            .onAppear {
                let settings = SettingsStore.shared
                if settings.isPreferredLaunchScreenEnabled {
                    selectedView = settings.preferredLaunchScreen
                }
            }
#elseif os(tvOS)
        tvOSBarView
#endif
    }
    
#if os(tvOS)
    private var tvOSBarView: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
                    .labelStyle(.titleOnly)
            }
            
            NavigationStack {
                ExploreView()
            }
            .tag(ExploreView.tag)
            .tabItem { Label("Explore", systemImage: "film").labelStyle(.titleOnly) }
            
            NavigationStack {
                WatchlistView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
            .tabItem {
                Label("Watchlist", systemImage: "square.stack.fill")
                    .labelStyle(.titleOnly)
            }
            
            NavigationStack {
                TVSearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.titleOnly)
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
        }
    }
#endif
    
#if os(iOS)
    private var iOSBarView: some View {
        TabView(selection: $selectedView) {
            NavigationStack {
                HomeView()
            }
            .tag(HomeView.tag)
            .tabItem { Label("Home", systemImage: "house") }
            
            NavigationStack {
                ExploreView()
            }
            .tag(ExploreView.tag)
            .tabItem { Label("Explore", systemImage: "film") }
            
            NavigationStack {
                WatchlistView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
            .tag(WatchlistView.tag)
            .tabItem {
                Label("Watchlist", systemImage: "square.stack.fill")
            }
            
            NavigationStack {
                SearchView()
            }
            .tag(SearchView.tag)
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
        .appTheme()
    }
#endif
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
