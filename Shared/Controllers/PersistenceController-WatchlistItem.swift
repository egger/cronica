//
//  PersistenceController-WatchlistItem.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import Foundation
import CoreData

extension PersistenceController {
    /// Adds an WatchlistItem to  Core Data.
    ///
    /// This function will automatically check if the item is saved in the list.
    ///
    /// If the item is saved, it will not create another instance of it.
    /// - Parameter content: The item to be added, or updated.
    func save(_ content: ItemContent) {
        if !self.isItemSaved(id: content.id, type: content.itemContentMedia) {
            let item = WatchlistItem(context: container.viewContext)
            item.contentType = content.itemContentMedia.toInt
            item.title = content.itemTitle
            item.originalTitle = content.originalTitle
            item.id = Int64(content.id)
            item.tmdbID = Int64(content.id)
            item.contentID = content.itemNotificationID
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
            saveContext()
        }
    }
    
    /// Fetch an item from Watchlist Core Data stack.
    /// - Parameters:
    ///   - id: The ID for the desired item.
    ///   - media: The MediaType for the desired item.
    /// - Returns: If the item exists, it will return an WatchlistItem, else it will return nil.
    func fetch(for id: Int64, media: MediaType) throws -> WatchlistItem? {
        let viewContext = container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let idPredicate = NSPredicate(format: "id == %d", id)
        let typePredicate = NSPredicate(format: "contentType == %d", media.toInt)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [idPredicate, typePredicate])
        request.predicate = compoundPredicate
        do {
            let items = try viewContext.fetch(request)
            if !items.isEmpty {
                return items[0]
            } else {
                return nil
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "PersistenceController.fetch(for:)")
            return nil
        }
    }
    
    /// Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent, isWatched watched: Bool? = nil, isFavorite favorite: Bool? = nil) {
        if isItemSaved(id: content.id, type: content.itemContentMedia) {
            do {
                let item = try fetch(for: WatchlistItem.ID(content.id), media: content.itemContentMedia)
                if let item {
                    item.contentID = content.itemNotificationID
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
                        if item.isWatching && !item.isArchive && !item.displayOnUpNext {
                            if item.nextEpisodeUpNext != 0 && item.seasonNumberUpNext != 0 {
                                Task {
                                    let network = NetworkService.shared
                                    let season = try? await network.fetchSeason(id: content.id, season: Int(item.seasonNumberUpNext))
                                    if let episodes = season?.episodes {
                                        if episodes.count < item.nextEpisodeUpNext {
                                            let nextSeasonNumber = Int(item.seasonNumberUpNext) + 1
                                            let newSeason = try? await network.fetchSeason(id: content.id, season: nextSeasonNumber)
                                            if let episodes = newSeason?.episodes {
                                                let firstEpisode = episodes[0]
                                                if firstEpisode.isItemReleased {
                                                    item.displayOnUpNext = true
                                                    item.seasonNumberUpNext = Int64(nextSeasonNumber)
                                                    item.nextEpisodeNumberUpNext = Int64(firstEpisode.itemEpisodeNumber)
                                                }
                                            }
                                        } else {
                                            let episode = episodes[Int(item.nextEpisodeUpNext)]
                                            if episode.isItemReleased {
                                                item.displayOnUpNext = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        item.date = content.itemFallbackDate
                    }
                    if let watched {
                        item.watched = watched
                    }
                    if let favorite {
                        item.favorite = favorite
                    }
                    item.lastValuesUpdated = Date()
                }
                saveContext()
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
                notification.removeNotification(identifier: content.notificationID)
            }
            viewContext.delete(item)
            saveContext()
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "PersistenceController.delete")
        }
    }
    
    func updateMarkAs(items: Set<String>) {
        var list = [WatchlistItem]()
        for item in items {
            let type = item.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = item.dropLast(2)
            let content = try? fetch(for: Int64(id)!, media: media)
            if let content {
                list.append(content)
            }
        }
        if !list.isEmpty {
            for item in list {
                updateMarkAs(id: item.itemId, type: item.itemMedia, watched: !item.watched)
            }
        }
    }
    
    func updatePin(items: Set<String>) {
        var list = [WatchlistItem]()
        for item in items {
            let type = item.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = item.dropLast(2)
            let content = try? fetch(for: Int64(id)!, media: media)
            if let content {
                list.append(content)
            }
        }
        if !list.isEmpty {
            for item in list {
                item.isPin.toggle()
            }
            saveContext()
        }
    }
    
    private func updatePin(for item: WatchlistItem) {
        item.isPin.toggle()
        saveContext()
    }
    
    func updateArchive(items: Set<String>) {
        var list = [WatchlistItem]()
        for item in items {
            let type = item.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = item.dropLast(2)
            let content = try? fetch(for: Int64(id)!, media: media)
            if let content {
                list.append(content)
            }
        }
        if !list.isEmpty {
            for item in list {
                // Removes notification (if available) for an item before setting it as archive.
                if !item.isArchive {
                    NotificationManager.shared.removeNotification(identifier: item.notificationID)
                }
                item.isArchive.toggle()
                item.shouldNotify.toggle()
            }
            saveContext()
        }
    }
    
    private func markAsArchive(_ item: WatchlistItem) {
        if item.isTvShow { item.isWatching.toggle() }
        item.isArchive.toggle()
        saveContext()
    }
    
    /// Updates the "watched" and/or the "favorite" property of an array of WatchlistItem in Core Data.
    func updateMarkAs(items: Set<WatchlistItem>, favorite: Bool? = nil, watched: Bool? = nil) {
        for item in items {
            if let favorite {
                updateMarkAs(id: item.itemId, type: item.itemMedia, favorite: favorite)
            }
            if let watched {
                updateMarkAs(id: item.itemId, type: item.itemMedia, watched: watched)
            }
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    func isNotificationScheduled(for content: WatchlistItem) -> Bool {
        let item = try? fetch(for: content.id, media: content.itemMedia)
        if let item {
            return item.notify
        }
        return false
    }
    
    /// Search if an item is added to the list.
    /// - Parameters:
    ///   - id: The ID used to fetch Watchlist list.
    ///   - type: The Media Type of the content.
    /// - Returns: Returns true if the content is already added to the Watchlist.
    func isItemSaved(id: ItemContent.ID, type: MediaType) -> Bool {
        let viewContext = container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", WatchlistItem.ID(id))
        let numberOfObjects = try? viewContext.count(for: request)
        if let numberOfObjects {
            if numberOfObjects > 0 {
                let item = try? fetch(for: WatchlistItem.ID(id), media: type)
                if let item {
                    if item.itemMedia != type {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func updateMarkAs(id: Int, type: MediaType, watched: Bool? = nil, favorite: Bool? = nil) {
        do {
            let item = try fetch(for: WatchlistItem.ID(id), media: type)
            if let item {
                if let watched {
                    item.watched = watched
                }
                if let favorite {
                    item.favorite = favorite
                }
                saveContext()
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
        }
    }
    
    func saveSeasons(for id: Int) async {
        do {
            let network = NetworkService.shared
            guard let item = try self.fetch(for: Int64(id), media: .tvShow) else { return }
            let content = try await network.fetchItem(id: item.itemId, type: .tvShow)
            var allEpisodes = [Episode]()
            if let seasonNumbers = content.itemSeasons {
                for season in seasonNumbers {
                    let result = try await network.fetchSeason(id: item.itemId, season: season)
                    if let episodes = result.episodes {
                        allEpisodes.append(contentsOf: episodes)
                    }
                }
            }
            if !allEpisodes.isEmpty {
                self.updateEpisodeList(to: item, show: item.itemId, episodes: allEpisodes)
            }
        } catch {
            
        }
    }
    
    func updateEpisodeList(to item: WatchlistItem, show: Int, episodes: [Episode]) {
        var watched = ""
        for episode in episodes {
            watched.append("-\(episode.id)@\(episode.itemSeasonNumber)")
        }
        item.watchedEpisodes?.append(watched)
        item.isWatching = true
        saveContext()
    }
    
    func updateEpisodeListUpTo(to id: Int, actualEpisode: Episode) async {
        do {
            let item = try self.fetch(for: Int64(id), media: .tvShow)
            guard let item else { return }
            let network = NetworkService.shared
            var watched = ""
            let actualSeason = actualEpisode.itemSeasonNumber
            let nextEpisode = actualEpisode.itemEpisodeNumber + 1
            let seasonsToFetch = Array(1...actualSeason)
            for season in seasonsToFetch {
                let result = try await network.fetchSeason(id: item.itemId, season: season)
                if let episodes = result.episodes {
                    for episode in episodes {
                        if episode.itemSeasonNumber == actualSeason && episode.itemEpisodeNumber == nextEpisode {
                            break
                        } else {
                            watched.append("-\(episode.id)@\(episode.itemSeasonNumber)")
                        }
                    }
                }
            }
            item.watchedEpisodes?.append(watched)
            print("watched episodes up to = \(watched)")
            item.isWatching = true
            saveContext()
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
        }
    }
    
    func updateEpisodeList(show: Int, season: Int, episode: Int, nextEpisode: Episode? = nil) {
        if isItemSaved(id: show, type: .tvShow) {
            do {
                let item = try fetch(for: WatchlistItem.ID(show), media: .tvShow)
                guard let item else { return }
                if isEpisodeSaved(show: show, season: season, episode: episode) {
                    let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode)@\(season)", with: "")
                    item.watchedEpisodes = watched
                } else {
                    let watched = "-\(episode)@\(season)"
                    item.watchedEpisodes?.append(watched)
                    item.isWatching = true
                    
                    if let nextEpisode {
                        item.nextEpisodeUpNext = Int64(nextEpisode.id)
                        item.nextEpisodeNumberUpNext = Int64(nextEpisode.episodeNumber ?? 0)
                        item.seasonNumberUpNext = Int64(nextEpisode.seasonNumber ?? 0)
                        if nextEpisode.isItemReleased {
                            item.displayOnUpNext = true
                        } else {
                            item.displayOnUpNext = false
                        }
                    } else {
                        item.displayOnUpNext = false
                    }
                    item.lastSelectedSeason = Int64(season)
                    item.lastWatchedEpisode = Int64(episode)
                }
                saveContext()
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
            }
            
        }
    }
    
    func fetchLastSelectedSeason(for id: Int64) -> Int? {
        let item = try? fetch(for: id, media: .tvShow)
        guard let item else { return nil }
        if item.lastSelectedSeason == 0 { return 1 }
        return Int(item.lastSelectedSeason)
    }
    
    func fetchLastWatchedEpisode(for id: Int64) -> Int? {
        let item = try? fetch(for: id, media: .tvShow)
        guard let item else { return nil }
        if !item.isWatching { return nil }
        if item.lastWatchedEpisode == 0 { return nil }
        return Int(item.lastWatchedEpisode)
    }
    
    func isEpisodeSaved(show: Int, season: Int, episode: Int) -> Bool {
        if isItemSaved(id: show, type: .tvShow) {
            let item = try? fetch(for: WatchlistItem.ID(show), media: .tvShow)
            if let item {
                if let watched = item.watchedEpisodes {
                    if watched.contains("-\(episode)@\(season)") {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    /// Returns a boolean indicating the status of 'watched' on a given item.
    func isMarkedAsWatched(id: ItemContent.ID, type: MediaType) -> Bool {
        let item = try? fetch(for: WatchlistItem.ID(id), media: type)
        return item?.watched ?? false
    }
    
    /// Returns a boolean indicating the status of 'favorite' on a given item.
    func isMarkedAsFavorite(id: ItemContent.ID, type: MediaType) -> Bool {
        let item = try? fetch(for: WatchlistItem.ID(id), media: type)
        return item?.favorite ?? false
    }
    
    func isItemPinned(id: ItemContent.ID, type: MediaType) -> Bool {
        let item = try? fetch(for: WatchlistItem.ID(id), media: type)
        return item?.isPin ?? false
    }
    
    func isItemArchived(id: ItemContent.ID, type: MediaType) -> Bool {
        let item = try? fetch(for: WatchlistItem.ID(id), media: type)
        return item?.isArchive ?? false
    }
    
    func fetchAllItemsIDs(_ media: MediaType) -> [String] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let typePredicate = NSPredicate(format: "contentType == %d", media.toInt)
        request.predicate = typePredicate
        do {
            let list = try container.viewContext.fetch(request)
            var ids = [String]()
            for item in list {
                ids.append(item.notificationID)
            }
            return ids
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "BackgroundManager.fetchAllItemsIDs()")
            return []
        }
    }
}
