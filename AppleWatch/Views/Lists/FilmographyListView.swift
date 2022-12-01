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
                    Divider()
                        .padding([.horizontal, .bottom])
                        .foregroundColor(.secondary)
                    TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
                    LazyVStack {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                                    .task {
                                        isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                                        if isInWatchlist {
                                            isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                                        }
                                    }
                            }
                        }
                    }
                    Divider()
                        .padding([.horizontal, .top])
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FilmographyListView_Previews: PreviewProvider {
    static var previews: some View {
        FilmographyListView(items: ItemContent.previewContents)
    }
}
