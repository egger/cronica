//
//  View-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

extension View {
    func watchlistContextMenu(item: WatchlistItem,
                              isWatched: Binding<Bool>,
                              isFavorite: Binding<Bool>,
                              isPin: Binding<Bool>,
                              isArchive: Binding<Bool>) -> some View {
        modifier(WatchlistItemContextMenu(item: item,
                                          isWatched: isWatched,
                                          isFavorite: isFavorite,
                                          isPin: isPin,
                                          isArchive: isArchive))
    }
    
    func itemContentContextMenu(item: ItemContent,
                                isWatched: Binding<Bool>,
                                showConfirmation: Binding<Bool>,
                                isInWatchlist: Binding<Bool>) -> some View {
        modifier(ItemContentContextMenu(item: item,
                                        showConfirmation: showConfirmation,
                                        isInWatchlist: isInWatchlist,
                                        isWatched: isWatched))
    }
    
    func applyHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
}
