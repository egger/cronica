//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @State private var isInWatchlist = false
    @State private var isWatched = false
    private let context = PersistenceController.shared
    var isSidebar = false
    var body: some View {
        if item.media == .person {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .draggable(item)
                    .contextMenu {
                        ShareLink(item: item.itemSearchURL)
                    }
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .draggable(item)
                        .contextMenu {
                            ShareLink(item: item.itemSearchURL)
                        }
                }
            }
        } else {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .draggable(item)
                    .task {
                        isInWatchlist = context.isItemSaved(id: item.id, type: item.media)
                        if isInWatchlist {
                            isWatched = context.isMarkedAsWatched(id: item.id, type: item.media)
                        }
                    }
                    .modifier(
                        ItemContentContextMenu(item: item,
                                               showConfirmation: $showConfirmation,
                                               isInWatchlist: $isInWatchlist,
                                               isWatched: $isWatched)
                    )
                    .modifier(
                        SearchItemSwipeGesture(item: item,
                                               showConfirmation: $showConfirmation,
                                               isInWatchlist: $isInWatchlist,
                                               isWatched: $isWatched)
                    )
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .draggable(item)
                        .task {
                            isInWatchlist = context.isItemSaved(id: item.id, type: item.media)
                            if isInWatchlist {
                                isWatched = context.isMarkedAsWatched(id: item.id, type: item.media)
                            }
                        }
                        .modifier(
                            ItemContentContextMenu(item: item,
                                                   showConfirmation: $showConfirmation,
                                                   isInWatchlist: $isInWatchlist,
                                                   isWatched: $isWatched)
                        )
                        .modifier(
                            SearchItemSwipeGesture(item: item,
                                                   showConfirmation: $showConfirmation,
                                                   isInWatchlist: $isInWatchlist,
                                                   isWatched: $isWatched)
                        )
                }
            }
            
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        SearchItemView(item: ItemContent.previewContent, showConfirmation: $show)
    }
}
