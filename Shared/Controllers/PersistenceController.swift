//
//  PersistenceController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import CloudKit
import TelemetryClient

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// tracking watchlists, and dealing with sample data.
struct PersistenceController {
    private let containerId = "iCloud.dev.alexandremadeira.Story"
    static let shared = PersistenceController()
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
    
    /// The lone CloudKit container used to store all  data.
    let container: NSPersistentCloudKitContainer
    
    /// Generate a data controller, in memory (for testing and previewing), or on permanent
    /// storage (for regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Watchlist")
        let description = container.persistentStoreDescriptions.first
        description?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerId)
        
        // For testing and previewing purposes, we create a temporary database that is destroyed
        // after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores {storeDescription, error in
            if let error {
#if targetEnvironment(simulator)
                print(error as Any)
#else
                TelemetryManager.send("containerError", with: ["error":"\(error.localizedDescription)"])
#endif
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Adds an WatchlistItem to  Core Data.
    /// - Parameter content: The item to be added, or updated.
    func save(_ content: ItemContent) {
        let viewContext = container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.contentType = content.itemContentMedia.toInt
        item.title = content.itemTitle
        item.id = Int64(content.id)
        item.image = content.cardImageMedium
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
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    /// Get an item from the Watchlist.
    /// - Parameter id: The ID used to fetch the list.
    /// - Returns: If the item is in the list, it will return it.
    func fetch(for id: WatchlistItem.ID) -> WatchlistItem? {
        let viewContext = container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        let item = try? viewContext.fetch(request)
        if let item {
            return item[0]
        }
        return nil
    }
    
    // Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent, isWatched watched: Bool? = nil, isFavorite favorite: Bool? = nil) {
        if isItemSaved(id: content.id, type: content.itemContentMedia) {
            let viewContext = container.viewContext
            let item = self.fetch(for: WatchlistItem.ID(content.id))
            if let item {
                item.title = content.itemTitle
                item.image = content.cardImageMedium
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
                if viewContext.hasChanges {
                    try? viewContext.save()
                }
            }
        } else {
            self.save(content)
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    func delete(_ content: WatchlistItem) {
        let viewContext = container.viewContext
        let item = try? viewContext.existingObject(with: content.objectID)
        if let item {
            if isNotificationScheduled(for: content) {
                let notification = NotificationManager.shared
                notification.removeNotification(identifier: "\(content.itemTitle)+\(content.id)")
            }
            viewContext.delete(item)
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }
    
    func delete(items: Set<Int64>) {
        var content = [WatchlistItem]()
        for item in items {
            let fetch = fetch(for: item)
            if let fetch {
                content.append(fetch)
            }
        }
        if !content.isEmpty {
            for item in content {
                delete(item)
            }
        }
    }
    
    func updateMarkAs(items: Set<Int64>) {
        var content = [WatchlistItem]()
        for item in items {
            let fetch = fetch(for: item)
            if let fetch {
                content.append(fetch)
            }
        }
        if !content.isEmpty {
            for item in content {
                updateMarkAs(id: item.itemId, watched: !item.watched)
            }
        }
    }
    
    func updateMarkAs(items: Set<WatchlistItem>, favorite: Bool? = nil, watched: Bool? = nil) {
        for item in items {
            if let favorite {
                updateMarkAs(id: item.itemId, favorite: favorite)
            }
            if let watched {
                updateMarkAs(id: item.itemId, watched: watched)
            }
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    private func isNotificationScheduled(for content: WatchlistItem) -> Bool {
        let item = fetch(for: content.id)
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
                let item = fetch(for: WatchlistItem.ID(id))
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
    
    func updateMarkAs(id: Int, watched: Bool? = nil, favorite: Bool? = nil) {
        let viewContext = container.viewContext
        let item = self.fetch(for: WatchlistItem.ID(id))
        if let item {
            if let watched {
                item.watched = watched
            }
            if let favorite {
                item.favorite = favorite
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }
    
    func updateEpisodeList(show: Int, season: Int, episode: Int) {
        let viewContext = container.viewContext
        if isItemSaved(id: show, type: .tvShow) {
            let item = fetch(for: WatchlistItem.ID(show))
            if let item {
                if isEpisodeSaved(show: show, season: season, episode: episode) {
                    let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode)@\(season)", with: "")
                    item.watchedEpisodes = watched
                } else {
                    let watched = "-\(episode)@\(season)"
                    item.watchedEpisodes?.append(watched)
                }
                if viewContext.hasChanges {
                    try? viewContext.save()
                }
            }
        }
    }
    
    func isEpisodeSaved(show: Int, season: Int, episode: Int) -> Bool {
        if isItemSaved(id: show, type: .tvShow) {
            let item = fetch(for: WatchlistItem.ID(show))
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
    func isMarkedAsWatched(id: ItemContent.ID) -> Bool {
        let item = fetch(for: WatchlistItem.ID(id))
        if let item {
            return item.watched
        }
        return false
    }
    
    // Returns a boolean indicating the status of 'favorite' on a given item.
    func isMarkedAsFavorite(id: ItemContent.ID) -> Bool {
        let item = fetch(for: WatchlistItem.ID(id))
        if let item {
            return item.favorite
        }
        return false
    }
}
