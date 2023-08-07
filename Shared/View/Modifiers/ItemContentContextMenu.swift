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
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    @Binding var isArchive: Bool
    private let context = PersistenceController.shared
    @Binding var showNote: Bool
    @Binding var showCustomListView: Bool
    @Binding var popupType: ActionPopupItems?
    @StateObject private var settings = SettingsStore.shared
    func body(content: Content) -> some View {
#if !os(watchOS)
        return content
            .contextMenu {
#if os(iOS) || os(macOS)
                switch settings.shareLinkPreference {
                case .cronica: if let cronicaUrl { ShareLink(item: cronicaUrl) }
                case .tmdb: ShareLink(item: item.itemURL)
                }
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
#if !os(tvOS)
                    CustomListButton(id: item.itemContentID, showCustomListView: $showCustomListView)
                    Button {
                        showNote.toggle()
                    } label: {
                        Label("reviewTitle", systemImage: "note.text")
                    }
#endif
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
            .swipeActions(edge: .leading, allowsFullSwipe: settings.allowFullSwipe) {
                WatchlistButton(id: item.itemContentID,
                                isInWatchlist: $isInWatchlist,
                                showPopup: $showPopup,
                                showListSelector: $showCustomListView,
                                popupType: $popupType)
                .tint(isInWatchlist ? .red : .green)
                if isInWatchlist {
                    WatchedButton(id: item.itemContentID,
                                  isWatched: $isWatched,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: settings.allowFullSwipe) {
                if isInWatchlist {
                    PinButton(id: item.itemContentID,
                              isPin: $isPin,
                              popupType: $popupType,
                              showPopup: $showPopup)
                    .tint(.purple)
                    ArchiveButton(id: item.itemContentID,
                                  isArchive: $isArchive,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
                    .tint(.gray)
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
    
    private var cronicaUrl: URL? {
        let encodedTitle = item.itemTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let posterPath = item.posterPath ?? String()
        let encodedPoster = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: "https://alexandremadeira.dev/cronica/details?id=\(item.itemContentID)&img=\(encodedPoster ?? String())&title=\(encodedTitle ?? String())")
    }
}
