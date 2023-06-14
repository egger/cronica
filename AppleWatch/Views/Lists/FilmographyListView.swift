//
//  FilmographyListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct FilmographyListView: View {
    let items: [ItemContent]?
    @State private var isInWatchlist = false
    @State private var isWatched = false
    private let context = PersistenceController.shared
    var body: some View {
        if let items {
            if !items.isEmpty {
                VStack {
                    TitleView(title: "Filmography")
                    LazyVStack {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                                    .task {
                                        isInWatchlist = context.isItemSaved(id: item.itemContentID)
                                        if isInWatchlist {
                                            isWatched = context.isMarkedAsWatched(id: item.itemContentID)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FilmographyListView_Previews: PreviewProvider {
    static var previews: some View {
        FilmographyListView(items: ItemContent.examples)
    }
}
