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
    private let context = PersistenceController.shared
    var body: some View {
        if item.media == .person {
            NavigationLink(value: item) {
                SearchItem(item: item, isInWatchlist: $isInWatchlist)
                    .hoverEffect(.lift)
                    .draggable(item)
                    .contextMenu {
                        ShareLink(item: item.itemSearchURL)
                    }
            }
        } else {
            NavigationLink(value: item) {
                SearchItem(item: item, isInWatchlist: $isInWatchlist)
                    .hoverEffect(.lift)
                    .draggable(item)
                    .task {
                        isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                    }
                    .modifier(ItemContentContextMenu(item: item, showConfirmation: $showConfirmation, isInWatchlist: $isInWatchlist))
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


