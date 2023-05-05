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
    @Binding var showConfirmation: Bool
    private let persistence = PersistenceController.shared
    private let notification = NotificationManager.shared
    var body: some View {
        Button(role: isInWatchlist ? .destructive : nil) {
            if !isInWatchlist { HapticManager.shared.successHaptic() }
            updateWatchlist()
        } label: {
            Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: isInWatchlist ? "minus.square" : "plus.square")
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
        do {
            let watchlistItem = try persistence.fetch(for: id)
            if let watchlistItem {
                if watchlistItem.notify {
                    notification.removeNotification(identifier: id)
                }
                persistence.delete(watchlistItem)
                withAnimation {
                    isInWatchlist.toggle()
                }
            }
        } catch {
            let message = "Can't remove item from Watchlist, error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message,
                                                  for: "ItemContentContextMenu.updateWatchlist")
        }
    }
    
    private func add() {
        Task {
            do {
                let identifier = id
                let type = identifier.last ?? "0"
                var media: MediaType = .movie
                if type == "1" {
                    media = .tvShow
                }
                let contentID = identifier.dropLast(2)
                let content = try await NetworkService.shared.fetchItem(id: Int(contentID)!, type: media)
                persistence.save(content)
                registerNotification(content)
                displayConfirmation()
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "ItemContentContextMenu.updateWatchlist")
            }
        }
    }
    
    private func registerNotification(_ item: ItemContent) {
        if item.itemCanNotify && item.itemFallbackDate.isLessThanTwoMonthsAway() {
            notification.schedule(item)
        }
    }
    
    private func displayConfirmation() {
        withAnimation {
            showConfirmation.toggle()
            isInWatchlist.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                showConfirmation = false
            }
        }
    }
}

struct WatchlistButton_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistButton(id: ItemContent.example.itemNotificationID,
                        isInWatchlist: .constant(true), showConfirmation: .constant(false))
    }
}
