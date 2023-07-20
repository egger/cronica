//
//  WatchlistItemContextMenu.swift
//  Shared
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemContextMenu: ViewModifier {
    let item: WatchlistItem
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    @Binding var isArchive: Bool
    @Binding var showNote: Bool
    @Binding var showCustomListView: Bool
    @Binding var popupType: ActionPopupItems?
    @Binding var showPopup: Bool
    private let context = PersistenceController.shared
    private let notification = NotificationManager.shared
    private let settings = SettingsStore.shared
    func body(content: Content) -> some View {
#if os(watchOS)
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
//                watchedButton
//                    .tint(item.isWatched ? .yellow : .green)
//                pinButton
//                    .tint(item.isPin ? .gray : .teal)
//                favoriteButton
//                    .tint(item.isFavorite ? .orange : .blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                deleteButton
//                archiveButton
            }
#elseif os(tvOS)
        return content
            .contextMenu {
                watchedButton
                favoriteButton
                pinButton
                archiveButton
                deleteButton
            }
#else
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: settings.allowFullSwipe) {
                primaryLeftSwipeActions
                secondaryLeftSwipeActions
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: settings.allowFullSwipe) {
                primaryRightSwipeActions
                secondaryRightSwipeActions
            }
            .contextMenu {
                share
                watchedButton
                favoriteButton
                pinButton
                archiveButton
                customListButton
                reviewButton
                Divider()
                deleteButton
            } preview: {
                ContextMenuPreviewImage(title: item.itemTitle,
                                        image: item.itemImage,
                                        overview: item.itemPreviewOverview)
            }
#endif
    }
    
    private var watchedButton: some View {
        WatchedButton(id: item.itemContentID,
                      isWatched: $isWatched,
                      popupType: $popupType,
                      showPopup: $showPopup)
    }
    
    private var favoriteButton: some View {
        FavoriteButton(id: item.itemContentID,
                       isFavorite: $isFavorite,
                       popupType: $popupType,
                       showPopup: $showPopup)
    }
    
    private var pinButton: some View {
        PinButton(id: item.itemContentID,
                  isPin: $isPin,
                  popupType: $popupType,
                  showPopup: $showPopup)
    }
    
    private var archiveButton: some View {
        ArchiveButton(id: item.itemContentID,
                      isArchive: $isArchive,
                      popupType: $popupType,
                      showPopup: $showPopup)
    }
    
#if os(iOS) || os(macOS)
    private var customListButton: some View {
        CustomListButton(id: item.itemContentID, showCustomListView: $showCustomListView)
    }
#endif
    
    private var reviewButton: some View {
        Button {
            showNote.toggle()
        } label: {
            Label("reviewTitle", systemImage: "note.text")
        }
    }
    
    private var share: some View {
#if os(iOS)
        ShareLink(item: item.itemUrlProxy)
#else
        EmptyView()
#endif
    }
    
    @ViewBuilder
    private var primaryLeftSwipeActions: some View {
        switch settings.primaryLeftSwipe {
        case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
        case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
        case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
        case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
        case .delete: deleteButton
        case .share: share
        }
    }
    
    @ViewBuilder
    private var secondaryLeftSwipeActions: some View {
        switch settings.secondaryLeftSwipe {
        case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
        case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
        case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
        case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
        case .delete: deleteButton
        case .share: share
        }
    }
    
    @ViewBuilder
    private var primaryRightSwipeActions: some View {
        switch  settings.primaryRightSwipe {
        case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
        case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
        case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
        case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
        case .delete: deleteButton
        case .share: share
        }
    }
    
    @ViewBuilder
    private var secondaryRightSwipeActions: some View {
        switch settings.secondaryRightSwipe {
        case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
        case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
        case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
        case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
        case .delete: deleteButton
        case .share: share
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: remove) {
#if os(macOS)
            Text("Remove")
                .foregroundColor(.red)
#else
            Label("Remove", systemImage: "minus.circle")
#endif
        }
        .tint(.red)
    }
    
    private func remove() {
        if item.notify { notification.removeNotification(identifier: item.itemContentID) }
        withAnimation { context.delete(item) }
    }
}
