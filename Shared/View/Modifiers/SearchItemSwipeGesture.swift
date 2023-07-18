//
//  SearchItemSwipeGesture.swift
//  Story
//
//  Created by Alexandre Madeira on 03/10/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct SearchItemSwipeGesture: ViewModifier {
    let item: ItemContent
    @Binding var showPopup: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @Binding var popupType: ActionPopupItems?
    @State private var isFavorite = false
    private let context = PersistenceController.shared
    private let network = NetworkService.shared
    @State private var isPin = false
    func body(content: Content) -> some View {
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if isInWatchlist {
                    WatchedButton(id: item.itemContentID,
                                  isWatched: $isWatched,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
                        .tint(isWatched ? .yellow : .green)
                    FavoriteButton(id: item.itemContentID,
                                   isFavorite: $isFavorite,
                                   popupType: $popupType,
                                   showPopup: $showPopup)
                        .tint(isFavorite ? .orange : .blue)
                } else {
                    WatchlistButton(id: item.itemContentID,
                                    isInWatchlist: $isInWatchlist,
                                    showPopup: $showPopup,
                                    showListSelector: .constant(false),
                                    popupType: $popupType)
                    .tint(.blue)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isInWatchlist {
                    WatchlistButton(id: item.itemContentID,
                                    isInWatchlist: $isInWatchlist,
                                    showPopup: $showPopup,
                                    showListSelector: .constant(false),
                                    popupType: $popupType)
                }
            }
    }
}
#endif
