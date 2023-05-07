//
//  PersistenceController-WatchlistItem.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import Foundation
import CoreData

extension PersistenceController {
    // MARK: Basic CRUD
    /// Creates a new WatchlistItem and saves it.
    /// - Parameter content: The content that is used to populate the new WatchlistItem.
    func save(_ content: ItemContent) {
        do {
            if !self.isItemSaved(id: content.itemContentID) {
                let item = WatchlistItem(context: container.viewContext)
                item.contentType = content.itemContentMedia.toInt
                item.title = content.itemTitle
                item.originalTitle = content.originalTitle
                item.id = Int64(content.id)
                item.tmdbID = Int64(content.id)
                item.contentID = content.itemContentID
                item.imdbID = content.imdbId
                item.image = content.cardImageMedium
                item.largeCardImage = content.cardImageLarge
                item.mediumPosterImage = content.posterImageMedium
                item.largePosterImage = content.posterImageLarge
                item.schedule = content.itemStatus.toInt
                item.notify = content.itemCanNotify
                item.genre = content.itemGenre
                item.lastValuesUpdated = Date()
                item.date = content.itemFallbackDate
                item.formattedDate = content.itemTheatricalString
                if content.itemContentMedia == .tvShow {
                    if let episode = content.lastEpisodeToAir?.episodeNumber {
                        item.nextEpisodeNumber = Int64(episode)
                    }
                    item.upcomingSeason = content.hasUpcomingSeason
                    item.nextSeasonNumber = Int64(content.nextEpisodeToAir?.seasonNumber ?? 0)
                }
                try save()
            }
        } catch {
            let message = "Failed to create item: \(content), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.save.failed")
        }
    }
    
    func fetch(for id: String) throws -> WatchlistItem? {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let idPredicate = NSPredicate(format: "contentID == %@", id)
        request.predicate = idPredicate
        do {
            let items = try container.viewContext.fetch(request)
            if !items.isEmpty {
                return items[0]
            }
            return nil
        } catch {
            let message = "Can't fetch content: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.fetch(for:)")
            return nil
        }
    }
    
    /// Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent) {
        if isItemSaved(id: content.itemContentID) {
            do {
                let item = try fetch(for: content.itemContentID)
                guard let item else { return }
                item.contentID = content.itemContentID
                item.tmdbID = Int64(content.id)
                item.title = content.itemTitle
                item.originalTitle = content.originalTitle
                item.image = content.cardImageMedium
                item.largeCardImage = content.cardImageLarge
                item.mediumPosterImage = content.posterImageMedium
                item.largePosterImage = content.posterImageLarge
                item.schedule = content.itemStatus.toInt
                item.notify = content.itemCanNotify
                item.formattedDate = content.itemTheatricalString
                item.genre = content.itemGenre
                if content.itemContentMedia == .tvShow {
                    if let episode = content.lastEpisodeToAir {
                        item.lastEpisodeNumber = Int64(episode.episodeNumber ?? 1)
                    }
                    if let episode = content.nextEpisodeToAir {
                        item.nextEpisodeNumber = Int64(episode.episodeNumber ?? 1)
                    }
                    item.upcomingSeason = content.hasUpcomingSeason
                    item.nextSeasonNumber = Int64(content.nextEpisodeToAir?.seasonNumber ?? 0)
                } else {
                    if let date = content.itemFallbackDate {
                        item.date = date
                    }
                }
                item.lastValuesUpdated = Date()
                try save()
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "PersistenceController.update")
            }
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    func delete(_ content: WatchlistItem) {
        let viewContext = container.viewContext
        do {
            let item = try viewContext.existingObject(with: content.objectID)
            if isNotificationScheduled(for: content) {
                let notification = NotificationManager.shared
                notification.removeNotification(identifier: content.itemContentID)
            }
            viewContext.delete(item)
            try save()
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "PersistenceController.delete")
        }
    }
    
    // MARK: Properties updates
    func updateWatched(for item: WatchlistItem) {
        do {
            item.watched.toggle()
            try save()
        } catch {
            let message = "Can't update item: \(item.itemContentID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updateWatched.failed")
        }
    }
    
    func updateFavorite(for item: WatchlistItem) {
        do {
            item.favorite.toggle()
            try save()
        } catch {
            let message = "Can't update item: \(item.itemContentID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updateFavorite.failed")
        }
    }
    
    func updatePin(for item: WatchlistItem) {
        do {
            item.isPin.toggle()
            try save()
        } catch {
            let message = "Can't update item: \(item.itemContentID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updatePin.failed")
        }
    }
    
    func updateArchive(for item: WatchlistItem) {
        do {
            item.isArchive.toggle()
            if !item.isArchive {
                // Removes notification (if available) for an item before setting it as archive.
                NotificationManager.shared.removeNotification(identifier: item.itemContentID)
                item.shouldNotify.toggle()
            }
            if item.isTvShow {
                item.isWatching = false
                item.displayOnUpNext = false
            }
            try save()
        } catch {
            let message = "Can't update item: \(item.itemContentID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updateArchive.failed")
        }
    }
    
    func updateReview(for item: WatchlistItem, rating: Int, notes: String) {
        do {
            item.userNotes = notes
            item.userRating = Int64(rating)
            try save()
        } catch {
            let message = "Can't update item: \(item.itemContentID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updateReview.failed")
        }
    }
    
    // MARK: Properties read
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    func isNotificationScheduled(for content: WatchlistItem) -> Bool {
        do {
            let item = try fetch(for: content.itemContentID)
            guard let notify = item?.notify else { return  false }
            return notify
        } catch {
            return false
        }
    }
    
    func isItemSaved(id: String) -> Bool {
        do {
            let viewContext = container.viewContext
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            request.predicate = NSPredicate(format: "contentID == %@", id)
            let numberOfObjects = try viewContext.count(for: request)
            if numberOfObjects > 0 {
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    /// Returns a boolean indicating the status of 'watched' on a given item.
    func isMarkedAsWatched(id: String) -> Bool {
        do {
            let item = try fetch(for: id)
            guard let item else { return false }
            return item.watched
        } catch {
            return false
        }
    }
    
    /// Returns a boolean indicating the status of 'favorite' on a given item.
    func isMarkedAsFavorite(id: String) -> Bool {
        do {
            let item = try fetch(for: id)
            guard let item else { return false }
            return item.favorite
        } catch {
            return false
        }
    }
    
    func isItemPinned(id: String) -> Bool {
        do {
            let item = try fetch(for: id)
            guard let item else { return false }
            return item.isPin
        } catch {
            return false
        }
    }
    
    func isItemArchived(id: String) -> Bool {
        do {
            let item = try fetch(for: id)
            guard let item else { return false }
            return item.isArchive
        } catch {
            return false
        }
    }
    
    // MARK: Episode
    func updateEpisodeList(to item: WatchlistItem, show: Int, episodes: [Episode]) {
        do {
            var watched = ""
            for episode in episodes {
                watched.append("-\(episode.id)@\(episode.itemSeasonNumber)")
            }
            item.watchedEpisodes?.append(watched)
            item.isWatching = true
            if let lastWatched = episodes.last {
                item.lastSelectedSeason = Int64(lastWatched.itemSeasonNumber)
                item.lastWatchedEpisode = Int64(lastWatched.id)
            }
            try save()
        } catch {
            if Task.isCancelled { return }
            let message = "\(error.localizedDescription), item id: \(show)"
            CronicaTelemetry.shared.handleMessage(message, for: "updateEpisodeList")
        }
    }
      
    func updateEpisodeList(show: Int, season: Int, episode: Int, nextEpisode: Episode? = nil) {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        if isItemSaved(id: contentId) {
            do {
                let item = try fetch(for: contentId)
                guard let item else { return }
                if isEpisodeSaved(show: show, season: season, episode: episode) {
                    let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode)@\(season)", with: "")
                    item.watchedEpisodes = watched
                    item.isWatching = true
                } else {
                    let watched = "-\(episode)@\(season)"
                    item.watchedEpisodes?.append(watched)
                    item.isWatching = true
                    
                    if let nextEpisode {
                        updateUpNext(item, episode: nextEpisode)
                    }
                    item.lastSelectedSeason = Int64(season)
                    item.lastWatchedEpisode = Int64(episode)
                    item.displayOnUpNext = true
                }
                try save()
            } catch {
                if Task.isCancelled { return }
                let message = "\(error.localizedDescription), item id: \(show)"
                CronicaTelemetry.shared.handleMessage(message, for: "updateEpisodeList")
            }
        }
    }
    
    func updateWatchedEpisodes(for item: WatchlistItem, with episode: Episode) {
        if isEpisodeSaved(show: item.itemId, season: episode.itemSeasonNumber, episode: episode.id) {
            let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode.id)@\(episode.itemSeasonNumber)",
                                                                     with: "")
            item.watchedEpisodes = watched
        } else {
            let watched = "-\(episode.id)@\(episode.itemSeasonNumber)"
            item.watchedEpisodes?.append(watched)
            item.lastSelectedSeason = Int64(episode.itemSeasonNumber)
            item.lastWatchedEpisode = Int64(episode.id)
        }
        item.isWatching = true
        try? save()
    }
    
    func removeFromUpNext(_ item: WatchlistItem) {
        item.displayOnUpNext = false
        try? save()
    }
    
    func updateUpNext(_ item: WatchlistItem, episode: Episode) {
        do {
            item.nextEpisodeNumberUpNext = Int64(episode.itemEpisodeNumber)
            item.seasonNumberUpNext = Int64(episode.itemSeasonNumber)
            item.displayOnUpNext = true
            try save()
        } catch {
            let message = "Item ID: \(item.itemContentID), episode: \(episode)"
            CronicaTelemetry.shared.handleMessage(message, for: "PersistenceController.updateUpNext.failed")
        }
    }
    
    func removeWatchedEpisodes(for item: WatchlistItem) {
        item.watchedEpisodes = String()
        item.displayOnUpNext = false
        item.isWatching = false
        try? save()
    }
    
    func getLastSelectedSeason(_ id: String) -> Int? {
        do {
            let item = try fetch(for: id)
            guard let item else { return nil }
            if item.lastSelectedSeason == 0 { return 1 }
            return Int(item.lastSelectedSeason)
        } catch {
            return nil
        }
    }
    
    func fetchLastWatchedEpisode(for id: Int) -> Int? {
        do {
            let contentId = "\(id)@\(MediaType.tvShow.toInt)"
            let item = try fetch(for: contentId)
            guard let item else { return nil }
            if !item.isWatching { return nil }
            if item.lastWatchedEpisode == 0 { return nil }
            return Int(item.lastWatchedEpisode)
        } catch {
            return nil
        }
    }
    
    func isEpisodeSaved(show: Int, season: Int, episode: Int) -> Bool {
        do {
            let contentId = "\(show)@\(MediaType.tvShow.toInt)"
            if isItemSaved(id: contentId) {
                let item = try fetch(for: contentId)
                guard let item, let watched = item.watchedEpisodes else { return false }
                if watched.contains("-\(episode)@\(season)") { return true }
            }
            return false
        } catch {
            return false
        }
    }
}
