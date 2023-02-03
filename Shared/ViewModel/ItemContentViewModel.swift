//
//  ItemContentViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  

import Foundation
import SwiftUI

@MainActor
class ItemContentViewModel: ObservableObject {
    private let service = NetworkService.shared
    private let notification = NotificationManager()
    private let persistence = PersistenceController.shared
    private var id: ItemContent.ID
    private var type: MediaType
    @Published var content: ItemContent?
    @Published var recommendations = [ItemContent]()
    @Published var credits = [Person]()
    @Published var errorMessage = "Something went wrong, try again later."
    @Published var showErrorAlert = false
    @Published var isInWatchlist = false
    @Published var isNotificationAvailable = false
    @Published var hasNotificationScheduled = false
    @Published var isWatched = false
    @Published var isFavorite = false
    @Published var isLoading = true
    @Published var showMarkAsButton = false
    init(id: ItemContent.ID, type: MediaType) {
        self.id = id
        self.type = type
    }
    
    func load() async {
        if Task.isCancelled { return }
        if content == nil {
            do {
                content = try await self.service.fetchItem(id: self.id, type: self.type)
                if let content {
                    isInWatchlist = persistence.isItemSaved(id: self.id, type: self.type)
                    withAnimation {
                        if isInWatchlist {
                            hasNotificationScheduled = isNotificationScheduled()
                            isWatched = persistence.isMarkedAsWatched(id: self.id, type: type)
                            isFavorite = persistence.isMarkedAsFavorite(id: self.id, type: type)
                        }
                        isNotificationAvailable = content.itemCanNotify
                        if content.itemStatus == .released {
                            showMarkAsButton = true
                        }
                    }
                    if recommendations.isEmpty {
                        recommendations.append(contentsOf: content.recommendations?.results.sorted { $0.itemPopularity > $1.itemPopularity } ?? [])
                    }
                    if credits.isEmpty {
                        let cast = content.credits?.cast ?? []
                        let crew = content.credits?.crew ?? []
                        let combined = cast + crew
                        credits.append(contentsOf: combined)
                    }
                    isLoading = false
                }
            } catch {
                if Task.isCancelled { return }
                showErrorAlert = true
                content = nil
                let message = """
Can't load the content with id: \(id) and media type: \(type.title), error: \(error.localizedDescription)
"""
                CronicaTelemetry.shared.handleMessage(message, for: "ItemContentViewModel.load()")
            }
        }
    }
    
    /// Automatically saves or delete an item from Watchlist and it's respective notification, if applicable.
    ///
    /// If an item already exists in Watchlist, it'll remove it from there and delete the scheduled notification.
    /// If an item don't exist yet in Watchlist, it'll add to it and schedule a notification, if needed.
    /// - Parameter item: The item to update the Watchlist with.
    func updateWatchlist(with item: ItemContent) {
        if isInWatchlist {
            // Removes item from Watchlist
            withAnimation {
                isInWatchlist.toggle()
            }
            do {
                let watchlistItem = try persistence.fetch(for: Int64(item.id), media: type)
                if let watchlistItem {
                    if watchlistItem.notify {
                        notification.removeNotification(identifier: item.itemNotificationID)
                        withAnimation {
                            hasNotificationScheduled.toggle()
                        }
                    }
                    persistence.delete(watchlistItem)
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            // Adds the item to Watchlist
            withAnimation {
                isInWatchlist.toggle()
            }
            persistence.save(item)
            if item.itemCanNotify {
                if item.itemFallbackDate.isLessThanTwoMonthsAway() {
                    NotificationManager.shared.schedule(notificationContent: item)
                }
                withAnimation {
                    hasNotificationScheduled.toggle()
                }
            }
        }
    }
    
    func updateMarkAs(markAsWatched watched: Bool? = nil, markAsFavorite favorite: Bool? = nil) {
        if !isInWatchlist {
            if let content {
                updateWatchlist(with: content)
            }
        }
        if let watched {
            withAnimation {
                isWatched.toggle()
            }
            persistence.updateMarkAs(id: id, type: type, watched: watched)
        }
        if let favorite {
            withAnimation {
                isFavorite.toggle()
            }
            persistence.updateMarkAs(id: id, type: type, favorite: favorite)
        }
    }
    
    func registerNotification() {
        if isInWatchlist && isNotificationAvailable && !hasNotificationScheduled && type == .tvShow {
            if let content {
                NotificationManager.shared.schedule(notificationContent: content)
                persistence.update(item: content)
            }
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    private func isNotificationScheduled() -> Bool {
        do {
            let item = try persistence.fetch(for: WatchlistItem.ID(self.id), media: type)
            if let item {
                return item.notify
            }
            return false
        } catch {
            return false
        }
    }
}
