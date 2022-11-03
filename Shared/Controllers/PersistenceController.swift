//
//  PersistenceController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import CloudKit
import Combine

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// tracking watchlists, and dealing with sample data.
struct PersistenceController {
    static let shared = PersistenceController()
    // MARK: Preview sample
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for item in ItemContent.previewContents {
            let newItem = WatchlistItem(context: viewContext)
            newItem.title = item.itemTitle
            newItem.id = Int64(item.id)
            newItem.image = item.cardImageMedium
            newItem.contentType = MediaType.movie.toInt
            newItem.notify = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Watchlist")
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
#if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
#else
                TelemetryErrorManager.shared.handleErrorMessage("\(error.localizedDescription)",
                                                                for: "containerError")
#endif
            }
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
        }
#if targetEnvironment(simulator)
        do {
            try container.initializeCloudKitSchema()
        } catch {
            TelemetryErrorManager.shared.handleErrorMessage("\(error.localizedDescription)",
                                                            for: "initializeCloudKitSchema")
        }
#endif
        return container
    }()
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
    // MARK: CRUD
    /// Save viewContext only if it has changes.
    private func saveContext() {
        let viewContext = container.viewContext
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
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
            if let theatrical = content.itemTheatricalDate {
                item.date = theatrical
            } else {
                item.date = content.itemFallbackDate
            }
            item.formattedDate = content.itemTheatricalString
            if content.itemContentMedia == .tvShow {
                if let episode = content.lastEpisodeToAir {
                    if let number = episode.episodeNumber {
                        item.nextEpisodeNumber = Int64(number)
                    }
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
            TelemetryErrorManager.shared.handleErrorMessage(error.localizedDescription,
                                                            for: "PersistenceController.fetch(for:)")
            return nil
        }
    }
    
    /// Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent, isWatched watched: Bool? = nil, isFavorite favorite: Bool? = nil) {
        if isItemSaved(id: content.id, type: content.itemContentMedia) {
            let item = try? fetch(for: WatchlistItem.ID(content.id), media: content.itemContentMedia)
            if let item {
                item.contentID = content.itemNotificationID
                item.tmdbID = Int64(content.id)
                item.title = content.itemTitle
                item.image = content.cardImageMedium
                item.largeCardImage = content.cardImageLarge
                item.mediumPosterImage = content.posterImageMedium
                item.largePosterImage = content.posterImageLarge
                item.schedule = content.itemStatus.toInt
                item.notify = content.itemCanNotify
                item.formattedDate = content.itemTheatricalString
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
                    if let theatrical = content.itemTheatricalDate {
                        item.date = theatrical
                    } else {
                        item.date = content.itemFallbackDate
                    }
                }
                if let watched {
                    item.watched = watched
                }
                if let favorite {
                    item.favorite = favorite
                }
                if container.viewContext.hasChanges {
                    item.lastValuesUpdated = Date()
                }
                saveContext()
            }
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    func delete(_ content: WatchlistItem) {
        let viewContext = container.viewContext
        let item = try? viewContext.existingObject(with: content.objectID)
        if let item {
            if isNotificationScheduled(for: content) {
                let notification = NotificationManager.shared
                notification.removeNotification(identifier: content.notificationID)
            }
            viewContext.delete(item)
            saveContext()
        }
    }

    func delete(items: Set<String>) {
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
                delete(item)
            }
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
    
    func markPinAs(item: WatchlistItem) {
        item.isPin.toggle()
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
                    }
                }
                return true
            }
        }
        return false
    }
    
    func updateMarkAs(id: Int, type: MediaType, watched: Bool? = nil, favorite: Bool? = nil) {
        let item = try? fetch(for: WatchlistItem.ID(id), media: type)
        if let item {
            if let watched {
                item.watched = watched
            }
            if let favorite {
                item.favorite = favorite
            }
            saveContext()
        }
    }
    
    func updateEpisodeList(show: Int, season: Int, episode: Int) {
        if isItemSaved(id: show, type: .tvShow) {
            let item = try? fetch(for: WatchlistItem.ID(show), media: .tvShow)
            if let item {
                if isEpisodeSaved(show: show, season: season, episode: episode) {
                    let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode)@\(season)", with: "")
                    item.watchedEpisodes = watched
                } else {
                    let watched = "-\(episode)@\(season)"
                    item.watchedEpisodes?.append(watched)
                    item.isWatching = true
                    item.lastSelectedSeason = Int64(season)
                    item.lastWatchedEpisode = Int64(episode)
                }
                saveContext()
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
}
