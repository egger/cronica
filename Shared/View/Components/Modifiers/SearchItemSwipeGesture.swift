//
//  SearchItemSwipeGesture.swift
//  Story
//
//  Created by Alexandre Madeira on 03/10/22.
//

import SwiftUI

struct SearchItemSwipeGesture: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    @AppStorage("showPinOnSearch") private var pinOnSearch = false
    @State private var isPin = false
    func body(content: Content) -> some View {
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if isInWatchlist {
                    watchedButton
                    favoriteButton
                } else {
                    Button(action: {
                        updateWatchlist(with: item)
                    }, label: {
                        Label("Add to watchlist", systemImage: "plus.square")
                    })
                    .tint(.blue)
                }
                if pinOnSearch {
                    Button(action: {
                        if !isInWatchlist {
                            updateWatchlist(with: item)
                        }
                        PersistenceController.shared.updatePin(items: [item.itemNotificationID])
                        isPin.toggle()
                    }, label: {
                        Label(isPin ? "Unpin Item" : "Pin Item",
                              systemImage: isPin ? "pin.slash.fill" : "pin.fill")
                    })
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isInWatchlist {
                    Button(role: .destructive, action: {
                        updateWatchlist(with: item)
                    }, label: {
                        Label("Remove from watchlist", systemImage: "minus.square")
                    })
                }
            }
    }
    
    private var watchedButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: !isWatched)
            withAnimation {
                isWatched.toggle()
            }
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
        .tint(isWatched ? .yellow : .green)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, favorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }, label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
        .tint(isFavorite ? .orange : .blue)
    }
    
    private func updateWatchlist(with item: ItemContent) {
        if isInWatchlist {
            withAnimation {
                isInWatchlist.toggle()
            }
            let watchlistItem = try? context.fetch(for: Int64(item.id), media: item.itemContentMedia)
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
