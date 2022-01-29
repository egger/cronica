//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: String? = "Watchlist"
    var body: some View {
        NavigationView {
            VStack {
                Text("Watchlist")
            }
            .navigationTitle("Watchlist")
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
