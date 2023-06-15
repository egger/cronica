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
    private let notification = NotificationManager.shared
    private let persistence = PersistenceController.shared
    private var id: ItemContent.ID
    private var type: MediaType
    @Published var content: ItemContent?
    @Published var watchlistItem: WatchlistItem?
    @Published var recommendations = [ItemContent]()
    @Published var credits = [Person]()
    @Published var errorMessage = "Something went wrong, try again later."
    @Published var showErrorAlert = false
    @Published var isInWatchlist = false
    private var isNotificationAvailable = false
    private var hasNotificationScheduled = false
    @Published var isWatched = false
    @Published var isFavorite = false
    @Published var isArchive = false
    @Published var isPin = false
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
                guard let content else { return }
                isInWatchlist = persistence.isItemSaved(id: content.itemContentID)
                if isInWatchlist {
                    watchlistItem = try persistence.fetch(for: content.itemContentID)
                }
                withAnimation {
                    if isInWatchlist {
                        hasNotificationScheduled = isNotificationScheduled()
                        isWatched = persistence.isMarkedAsWatched(id: content.itemContentID)
                        isFavorite = persistence.isMarkedAsFavorite(id: content.itemContentID)
                        isArchive = persistence.isItemArchived(id: content.itemContentID)
                        isPin = persistence.isItemPinned(id: content.itemContentID)
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
            } catch {
                if Task.isCancelled { return }
                showErrorAlert = true
                content = nil
                let message = "ID: \(id), type: \(type.title), error: \(error.localizedDescription)"
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
            withAnimation { isInWatchlist.toggle() }
            do {
                let watchlistItem = try persistence.fetch(for: item.itemContentID)
                guard let watchlistItem else { return }
                notification.removeNotification(identifier: item.itemContentID)
                persistence.delete(watchlistItem)
            } catch {
                CronicaTelemetry.shared.handleMessage("\(error.localizedDescription)",
                                                      for: "ItemContentViewModel.updateWatchlist.failed")
            }
        } else {
            // Adds the item to Watchlist
            withAnimation { isInWatchlist.toggle() }
            persistence.save(item)
            if item.itemCanNotify && item.itemFallbackDate.isLessThanTwoMonthsAway() {
                NotificationManager.shared.schedule(item)
            }
        }
    }
    
    func checkIfAdded() {
        guard let content else { return }
        if !isInWatchlist {
            let isSaved = persistence.isItemSaved(id: content.itemContentID) 
            if isSaved {
                withAnimation {
                    isInWatchlist = true
                }
            }
        } else {
            let isSaved = persistence.isItemSaved(id: content.itemContentID)
            if !isSaved {
                withAnimation {
                    isInWatchlist = false
                }
            }
        }
    }
    
    func registerNotification() {
        if isInWatchlist && !isArchive && isNotificationAvailable && !hasNotificationScheduled && type == .tvShow {
            if let content {
                NotificationManager.shared.schedule(content)
                persistence.update(item: content)
            }
        }
        if isInWatchlist && isNotificationAvailable && type == .movie {
            guard let content else { return }
            NotificationManager.shared.schedule(content)
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    private func isNotificationScheduled() -> Bool {
        do {
            guard let content else { return false }
            let item = try persistence.fetch(for: content.itemContentID)
            guard let notify = item?.notify else { return false }
            return notify
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "ItemContentViewModel.isNotificationScheduled")
            return false
        }
    }
    
    func fetchSavedItem() {
        guard let content else { return }
        watchlistItem = try? persistence.fetch(for: content.itemContentID)
    }
    
    func update(_ property: UpdateItemProperties) {
        guard let content else { return }
        if !isInWatchlist { updateWatchlist(with: content) }
        guard let item = try? persistence.fetch(for: content.itemContentID) else { return }
        switch property {
        case .watched:
            persistence.updateWatched(for: item)
            withAnimation { isWatched.toggle() }
            Task { await updateSeasons() }
        case .favorite:
            persistence.updateFavorite(for: item)
            withAnimation { isFavorite.toggle() }
        case .pin:
            persistence.updatePin(for: item)
            withAnimation { isPin.toggle() }
        case .archive:
            persistence.updateArchive(for: item)
            withAnimation { isArchive.toggle() }
        }
    }
    
    private func updateSeasons() async {
        if type != .tvShow { return }
        guard let content, let item = try? persistence.fetch(for: content.itemContentID) else { return }
        if !isWatched {
            /// if item is removed from watched, then all watched episodes will also be removed.
            persistence.removeWatchedEpisodes(for: item)
        } else {
            /// if item is marked as watched, all episodes will also be marked as watched.
            guard let seasons = content.seasons else { return }
            var episodes = [Episode]()
            for season in seasons {
                let result = try? await service.fetchSeason(id: content.id, season: season.seasonNumber)
                if let items = result?.episodes {
                    episodes.append(contentsOf: items)
                }
            }
            if !episodes.isEmpty {
                persistence.updateEpisodeList(to: item, show: item.itemId, episodes: episodes)
            }
        }
    }
}

enum UpdateItemProperties: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case watched, favorite, pin, archive
    
    var title: String {
        switch self {
        case .watched: return NSLocalizedString("Watched", comment: "")
        case .favorite: return NSLocalizedString("Favorite", comment: "")
        case .pin: return NSLocalizedString("Pin", comment: "")
        case .archive: return NSLocalizedString("Archive", comment: "")
        }
    }
}
