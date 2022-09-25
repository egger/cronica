//
//  PersistenceController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import CloudKit
import TelemetryClient
import Combine

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// tracking watchlists, and dealing with sample data.
class PersistenceController: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    private let containerId = "iCloud.dev.alexandremadeira.Story"
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
                TelemetryManager.send("containerError", with: ["error":"\(error.localizedDescription)"])
#endif
            }
            //storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.dev.alexandremadeira.Story")
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
        }
        #if DEBUG
        do {
            try container.initializeCloudKitSchema()
        } catch {
            fatalError(error.localizedDescription)
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
    private func saveContext() {
        let viewContext = container.viewContext
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    /// Adds an WatchlistItem to  Core Data.
    /// - Parameter content: The item to be added, or updated.
    func save(_ content: ItemContent) {
        let item = WatchlistItem(context: container.viewContext)
        item.contentType = content.itemContentMedia.toInt
        item.title = content.itemTitle
        item.id = Int64(content.id)
        item.image = content.cardImageMedium
        item.largeCardImage = content.cardImageLarge
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
        item.imdbID = content.imdbId
        saveContext()
#if targetEnvironment(simulator)
        print(content as Any)
        print(item as Any)
#endif
    }
    
    /// Get an item from the Watchlist.
    /// - Parameter id: The ID used to fetch the list.
    /// - Returns: If the item is in the list, it will return it.
    func fetch(for id: WatchlistItem.ID) throws -> WatchlistItem? {
        let viewContext = container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let items = try viewContext.fetch(request)
            if !items.isEmpty {
                return items[0]
            } else {
                return nil
            }
        } catch {
#if targetEnvironment(simulator)
            print("Error: PersistenceController.fetch(for:) with localized description of \(error.localizedDescription)")
#else
            TelemetryManager.send("PersistenceController.fetch(for:)", with: ["error":"\(error.localizedDescription)"])
#endif
            return nil
        }
    }
    
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
#if targetEnvironment(simulator)
            print("Error: PersistenceController.fetch(for:) with localized description of \(error.localizedDescription)")
#else
            TelemetryManager.send("PersistenceController.fetch(for:)", with: ["error":"\(error.localizedDescription)"])
#endif
            return nil
        }
    }
    
    /// Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent, isWatched watched: Bool? = nil, isFavorite favorite: Bool? = nil) {
        if isItemSaved(id: content.id, type: content.itemContentMedia) {
            let item = try? fetch(for: WatchlistItem.ID(content.id))
            if let item {
                item.title = content.itemTitle
                item.image = content.cardImageMedium
                item.largeCardImage = content.cardImageLarge
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
    
    ///  Deletes an array of WatchlistItem from Core Data.
    /// - Parameter items: The IDs of the items to be fetched from Core Data and then deleted.
    func delete(items: Set<Int64>) {
        var content = [WatchlistItem]()
        for item in items {
            let fetch = try? fetch(for: item)
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
    
    /// Updates the "watched" property of an array of WatchlistItem in Core Data.
    /// - Parameter items: The IDs of the items to be fetched from Core Data and then updated.
    func updateMarkAs(items: Set<Int64>) {
        var content = [WatchlistItem]()
        for item in items {
            let fetch = try? fetch(for: item)
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
    
    /// Updates the "watched" and/or the "favorite" property of an array of WatchlistItem in Core Data.
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
    func isNotificationScheduled(for content: WatchlistItem) -> Bool {
        let item = try? fetch(for: content.id)
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
                let item = try? fetch(for: WatchlistItem.ID(id))
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
        let item = try? fetch(for: WatchlistItem.ID(id))
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
            let item = try? fetch(for: WatchlistItem.ID(show))
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
            let item = try? fetch(for: WatchlistItem.ID(show))
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
        let item = try? fetch(for: WatchlistItem.ID(id))
        return item?.watched ?? false
    }
    
    /// Returns a boolean indicating the status of 'favorite' on a given item.
    func isMarkedAsFavorite(id: ItemContent.ID) -> Bool {
        let item = try? fetch(for: WatchlistItem.ID(id))
        return item?.favorite ?? false
    }
}
