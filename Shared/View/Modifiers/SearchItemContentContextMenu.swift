//
//  SearchItemContentContextMenu.swift
//  Story
//
//  Created by Alexandre Madeira on 29/10/23.
//

import SwiftUI

struct SearchItemContentContextMenu: ViewModifier {
    let item: SearchItemContent
    @Binding var showPopup: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
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
                    watchedButton
#if !os(tvOS)
                    CustomListButton(id: item.itemContentID, showCustomListView: $showCustomListView)
                    Button {
                        showNote.toggle()
                    } label: {
                        Label("reviewTitle", systemImage: "note.text")
                    }
#endif
#if DEBUG
                    printButton
#endif
                }
                Divider()
                if !isInWatchlist {
                    addAndMarkWatchedButton
                }
                watchlistButton
            } preview: {
                ContextMenuPreviewImage(title: item.itemTitle,
                                        image: item.cardImageLarge,
                                        overview: item.itemOverview)
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
    
    private var watchedButton: some View {
        WatchedButton(id: item.itemContentID,
                      isWatched: $isWatched,
                      popupType: $popupType,
                      showPopup: $showPopup)
    }
    
    private var watchlistButton: some View {
        WatchlistButton(id: item.itemContentID,
                        isInWatchlist: $isInWatchlist,
                        showPopup: $showPopup,
                        showListSelector: $showCustomListView,
                        popupType: $popupType)
    }
    
    @ViewBuilder
    private var printButton: some View {
#if DEBUG
        Button {
            print(item)
        } label: {
            Label("Print", systemImage: "hammer.fill")
        }
#endif
    }
    
    @ViewBuilder
    private var shareButton: some View {
#if !os(tvOS)
        switch settings.shareLinkPreference {
        case .cronica: if let cronicaUrl { ShareLink(item: cronicaUrl) }
        case .tmdb: ShareLink(item: item.itemURL)
        }
#else
        EmptyView()
#endif
    }
}
