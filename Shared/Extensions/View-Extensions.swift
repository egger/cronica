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
                                          isArchive: isPin))
    }
    
    func applyHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
}
