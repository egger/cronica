//
//  ItemContentContextMenu.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

struct ItemContentContextMenu: ViewModifier {
    let item: ItemContent
    @Binding var showPopup: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    private let context = PersistenceController.shared
    @Binding var showNote: Bool
    @Binding var showCustomListView: Bool
    @Binding var popupType: ActionPopupItems?
    func body(content: Content) -> some View {
#if os(watchOS)
#else
        return content
            .contextMenu {
#if os(iOS) || os(macOS)
                ShareLink(item: item.itemURL)
#endif
                if isInWatchlist {
                    WatchedButton(id: item.itemContentID,
                                  isWatched: $isWatched,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
                    FavoriteButton(id: item.itemContentID,
                                   isFavorite: $isFavorite,
                                   popupType: $popupType,
                                   showPopup: $showPopup)
                    PinButton(id: item.itemContentID,
                              isPin: $isPin,
                              popupType: $popupType,
                              showPopup: $showPopup)
                    ArchiveButton(id: item.itemContentID,
                                  isArchive: $isArchive,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
                    CustomListButton(id: item.itemContentID, showCustomListView: $showCustomListView)
                    Button {
                        showNote.toggle()
                    } label: {
                        Label("reviewTitle", systemImage: "note.text")
                    }
                }
                Divider()
                if !isInWatchlist {
                    addAndMarkWatchedButton
                }
                WatchlistButton(id: item.itemContentID,
                                isInWatchlist: $isInWatchlist,
                                showPopup: $showPopup,
                                showListSelector: $showCustomListView,
                                popupType: $popupType)
            } preview: {
                ContextMenuPreviewImage(title: item.itemTitle,
                                        image: item.cardImageLarge,
                                        overview: item.itemOverview)
            }
            .task {
                if isInWatchlist {
                    isFavorite = context.isMarkedAsFavorite(id: item.itemContentID)
                    isPin = context.isItemPinned(id: item.itemContentID)
                    isArchive = context.isItemArchived(id: item.itemContentID)
                }
            }
#endif
    }
    
    private var addAndMarkWatchedButton: some View {
        Button(action: addAndMarkAsWatched) {
            Label("addAndMarkWatchedButton", systemImage: "rectangle.badge.checkmark.fill")
        }
    }
    
    private func addAndMarkAsWatched() {
        Task {
            let item = try? await NetworkService.shared.fetchItem(id: self.item.id, type: self.item.itemContentMedia)
            guard let item else {
                context.save(self.item)
                HapticManager.shared.successHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isInWatchlist.toggle()
                        isWatched.toggle()
                    }
                }
                return
            }
            context.save(item)
            let content = context.fetch(for: item.itemContentID)
            guard let content else { return }
            context.updateWatched(for: content)
            HapticManager.shared.successHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isInWatchlist.toggle()
                    isWatched.toggle()
                }
            }
        }
    }
}
