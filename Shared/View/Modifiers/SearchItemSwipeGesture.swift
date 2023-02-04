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
            HapticManager.shared.successHaptic()
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
            HapticManager.shared.successHaptic()
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
                do {
                    let content = try await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                    context.save(content)
                    registerNotification(content)
                } catch {
                    if Task.isCancelled { return }
                    context.save(item)
                    registerNotification(item)
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                          for: "SearchItemSwipeGesture.updateWatchlist")
                }
                HapticManager.shared.successHaptic()
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
    
    private func registerNotification(_ item: ItemContent) {
        if item.itemCanNotify && item.itemFallbackDate.isLessThanTwoMonthsAway() {
            NotificationManager.shared.schedule(item)
        }
    }
}
