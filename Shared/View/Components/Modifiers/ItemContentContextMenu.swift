//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

@preconcurrency import SwiftUI

struct ItemContentContextMenu: ViewModifier, Sendable {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    func body(content: Content) -> some View {
        return content
            .contextMenu {
                ShareLink(item: item.itemURL)
                Button(action: {
                    updateWatchlist(with: item)
                }, label: {
                    Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                          systemImage: isInWatchlist ? "minus.square" : "plus.square")
                })
                if isInWatchlist {
                    watchedButton
                    favoriteButton
                }
            }
            .task {
                if isInWatchlist {
                    isWatched = context.isMarkedAsWatched(id: item.id)
                    isFavorite = context.isMarkedAsFavorite(id: item.id)
                }
            } 
    }
    
    private var watchedButton: some View {
        Button(action: {
            HapticManager.shared.softHaptic()
            context.updateMarkAs(id: item.id, watched: !isWatched)
            withAnimation {
                isWatched.toggle()
            }
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            HapticManager.shared.softHaptic()
            context.updateMarkAs(id: item.id, favorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }, label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private func updateWatchlist(with item: ItemContent) {
        HapticManager.shared.softHaptic()
        if isInWatchlist {
            withAnimation {
                isInWatchlist.toggle()
            }
            let watchlistItem = try? context.fetch(for: Int64(item.id))
            if let watchlistItem {
                if watchlistItem.notify {
                    NotificationManager.shared.removeNotification(identifier: watchlistItem.notificationID)
                }
                context.delete(watchlistItem)
            }
        } else {
            Task {
                let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                if let content {
                    context.save(content)
                    if content.itemCanNotify {
                        NotificationManager.shared.schedule(notificationContent: content)
                    }
                } else {
                    context.save(item)
                    if item.itemCanNotify {
                        NotificationManager.shared.schedule(notificationContent: item)
                    }
                }
            }
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
}
