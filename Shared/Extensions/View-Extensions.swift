//
//  View-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

extension View {
    func actionPopup(isShowing: Binding<Bool>, for item: ActionPopupItems?) -> some View {
        modifier(ConfirmationPopupModifier(isShowing: isShowing, item: item))
    }
    func watchlistContextMenu(item: WatchlistItem,
                              isWatched: Binding<Bool>,
                              isFavorite: Binding<Bool>,
                              isPin: Binding<Bool>,
                              isArchive: Binding<Bool>,
                              showNote: Binding<Bool>,
                              showCustomList: Binding<Bool>,
                              popupConfirmationType: Binding<ActionPopupItems?>,
                              showConfirmationPopup: Binding<Bool>) -> some View {
        modifier(WatchlistItemContextMenu(item: item,
                                          isWatched: isWatched,
                                          isFavorite: isFavorite,
                                          isPin: isPin,
                                          isArchive: isArchive,
                                          showNote: showNote,
                                          showCustomListView: showCustomList,
                                          popupConfirmationType: popupConfirmationType,
                                          showConfirmationPopup: showConfirmationPopup))
    }
    
    func itemContentContextMenu(item: ItemContent,
                                isWatched: Binding<Bool>,
                                showConfirmation: Binding<Bool>,
                                isInWatchlist: Binding<Bool>,
                                showNote: Binding<Bool>,
                                showCustomList: Binding<Bool>,
                                popupConfirmationType: Binding<ActionPopupItems?>,
                                showConfirmationPopup: Binding<Bool>) -> some View {
        modifier(ItemContentContextMenu(item: item,
                                        showConfirmation: showConfirmation,
                                        isInWatchlist: isInWatchlist,
                                        isWatched: isWatched,
                                        showNote: showNote,
                                        showCustomListView: showCustomList,
                                        popupType: popupConfirmationType,
                                        showConfirmationPopup: showConfirmationPopup))
    }
    
    func applyHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
    
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }
    
    func appTint() -> some View {
        modifier(AppTintModifier())
    }
}
