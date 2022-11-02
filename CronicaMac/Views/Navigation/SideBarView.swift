//
//  SideBarView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SideBarView: View {
    @AppStorage("selectedView") private var selectedView: Screens = .home
    @State private var showNotifications = false
    @StateObject private var searchViewModel = SearchViewModel()
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Screens.home) {
                    Label("Home", systemImage: "house")
                }
                
                NavigationLink(value: Screens.discover) {
                    Label("Explore", systemImage: "film")
                }
                
                NavigationLink(value: Screens.watchlist) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
            }
            .searchable(text: $searchViewModel.query,
                        placement: .toolbar,
                        prompt: "Movies, Shows, People")
            .navigationTitle("Cronica")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NavigationStack {
                    VStack {
                        Text("Hello")
                    }
                    .toolbar {
                        Button("Done") { showNotifications.toggle() }
                    }
                    .navigationTitle("Notifications")
                    .frame(width: 450, height: 500)
                }
            }
        } detail: {
            switch selectedView {
            case .home:
                HomeView()
            case .discover:
                DiscoverView()
            case .watchlist:
                WatchlistView()
            case .search:
                EmptyView()
            }
        }

    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
