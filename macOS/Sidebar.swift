//
//  Sidebar.swift
//  Story (macOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct Sidebar: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: HomeView()) {
                    Label("Home", systemImage: "house")
                }
                NavigationLink(destination: HomeView()) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                NavigationLink(destination: HomeView()) {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
            .navigationTitle("Cronica")
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
