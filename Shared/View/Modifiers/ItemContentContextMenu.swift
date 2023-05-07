//
//  ItemContentContextMenu.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

struct ItemContentContextMenu: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    private let context = PersistenceController.shared
    @Binding var showNote: Bool
    func body(content: Content) -> some View {
#if os(watchOS)
#else
        return content
            .contextMenu {
#if os(iOS) || os(macOS)
                ShareLink(item: item.itemURL)
#endif
                if isInWatchlist {
                    WatchedButton(id: item.itemNotificationID, isWatched: $isWatched)
                    FavoriteButton(id: item.itemNotificationID, isFavorite: $isFavorite)
                    PinButton(id: item.itemNotificationID, isPin: $isPin)
                    ArchiveButton(id: item.itemNotificationID, isArchive: $isArchive)
                    CustomListButton(id: item.itemNotificationID)
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
                WatchlistButton(id: item.itemNotificationID,
                                isInWatchlist: $isInWatchlist,
                                showConfirmation: $showConfirmation)
            } preview: {
                ContextMenuPreviewImage(title: item.itemTitle,
                                        image: item.cardImageLarge,
                                        overview: item.itemOverview)
            }
            .task {
                if isInWatchlist {
                    isFavorite = context.isMarkedAsFavorite(id: item.itemNotificationID)
                    isPin = context.isItemPinned(id: item.itemNotificationID)
                    isArchive = context.isItemArchived(id: item.itemNotificationID)
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
                return
            }
            context.save(item)
            let content = try? context.fetch(for: item.itemNotificationID)
            guard let content else { return }
            context.updateWatched(for: content)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { isWatched.toggle() }
            }
        }
    }
}
