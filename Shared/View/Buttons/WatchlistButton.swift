//
//  WatchlistButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct WatchlistButton: View {
    let id: String
    @Binding var isInWatchlist: Bool
    @Binding var showPopup: Bool
    @Binding var showListSelector: Bool
    @Binding var popupConfirmationType: ActionPopupItems?
    private let persistence = PersistenceController.shared
    private let notification = NotificationManager.shared
    var body: some View {
        Button(role: isInWatchlist ? .destructive : nil) {
            if !isInWatchlist { HapticManager.shared.successHaptic() }
            updateWatchlist()
        } label: {
            Label(isInWatchlist ? "Remove": "Add to watchlist",
                  systemImage: isInWatchlist ? "minus.circle" : "plus.circle")
#if os(macOS)
            .foregroundColor(isInWatchlist ? .red : nil)
            .labelStyle(.titleOnly)
#endif
        }
    }
    
    private func updateWatchlist() {
        if isInWatchlist {
            remove()
        } else {
            add()
        }
    }
    
    private func remove() {
        let watchlistItem = persistence.fetch(for: id)
        if let watchlistItem {
            if watchlistItem.notify {
                notification.removeNotification(identifier: id)
            }
            persistence.delete(watchlistItem)
            displayConfirmation()
        }
    }
    
    private func add() {
        Task {
            let identifier = id
            let type = identifier.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let contentID = identifier.dropLast(2)
            let content = try? await NetworkService.shared.fetchItem(id: Int(contentID)!, type: media)
            guard let content else { return }
            persistence.save(content)
            registerNotification(content)
            displayConfirmation()
            if content.itemContentMedia == .tvShow { addFirstEpisodeToUpNext(content) }
            if SettingsStore.shared.openListSelectorOnAdding {
                showListSelector.toggle()
            }
            popupConfirmationType = .addedWatchlist
        }
    }
    
    private func registerNotification(_ item: ItemContent) {
        if item.itemCanNotify && item.itemFallbackDate.isLessThanTwoWeeksAway() {
            notification.schedule(item)
        }
    }
    
    private func displayConfirmation() {
        withAnimation {
            showPopup.toggle()
            isInWatchlist.toggle()
            popupConfirmationType = isInWatchlist ? .addedWatchlist : .removedWatchlist
        }
    }
    
    private func addFirstEpisodeToUpNext(_ item: ItemContent) {
        Task {
            let firstSeason = try? await NetworkService.shared.fetchSeason(id: item.id, season: 1)
            guard let firstEpisode = firstSeason?.episodes?.first,
                  let content = persistence.fetch(for: item.itemContentID)
            else { return }
            persistence.updateUpNext(content, episode: firstEpisode)
        }
    }
}

struct WatchlistButton_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistButton(id: ItemContent.example.itemContentID,
                        isInWatchlist: .constant(true),
                        showPopup: .constant(false),
                        showListSelector: .constant(false),
                        popupConfirmationType: .constant(.addedWatchlist))
    }
}
