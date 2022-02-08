//
//  SideBar.swift
//  Story
//
//  Created by Alexandre Madeira on 30/01/22.
//

import SwiftUI

struct SideBar: View {
    @SceneStorage("selectedView") var selectedView: String?
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MovieView()) {
                    Label("Movies", systemImage: "film")
                }
                .tag(MovieView.tag)
                NavigationLink(destination: SeriesView()) {
                    Label("TV", systemImage: "play.tv")
                }
                .tag(SeriesView.tag)
                NavigationLink(destination: WatchlistView()) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                .tag(WatchlistView.tag)
                NavigationLink(destination: SearchView()) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(SearchView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Story")
            MovieView()
        }
        
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        SideBar()
    }
}
