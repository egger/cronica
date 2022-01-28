//
//  iPadView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/01/22.
//

import SwiftUI

struct iPadView: View {
    @SceneStorage("selectedView") var selectedView: String?
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MovieView()) {
                    Label("Movies", systemImage: "film")
                }
                .tag(MovieView.tag)
                NavigationLink(destination: TvView()) {
                    Label("TV", systemImage: "play.tv")
                }
                .tag(TvView.tag)
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

struct iPadView_Previews: PreviewProvider {
    static var previews: some View {
        iPadView()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    }
}
