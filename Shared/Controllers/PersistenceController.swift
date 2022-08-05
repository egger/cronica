//
//  PersistenceController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import SwiftUI

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// tracking watchlists, and dealing with sample data.
struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for item in ItemContent.previewContents {
            let newItem = WatchlistItem(context: viewContext)
            newItem.title = item.itemTitle
            newItem.id = Int64(item.id)
            newItem.image = item.cardImageMedium
            newItem.contentType = MediaType.movie.watchlistInt
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
        
        // For testing and previewing purposes, we create a temporary database that is destroyed
        // after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores {storeDescription, error in
            print(storeDescription.url as Any)
            if let error {
                print(error.localizedDescription)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    //MARK: CRUD operations.
    /// Adds an WatchlistItem to  Core Data.
    /// - Parameter content: The item to be added, or updated.
    func save(_ content: ItemContent) {
        let viewContext = container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.contentType = content.itemContentMedia.watchlistInt
        item.title = content.itemTitle
        item.id = Int64(content.id)
        item.image = content.cardImageMedium
        item.schedule = content.itemStatus.scheduleNumber
        item.notify = content.itemCanNotify
        item.formattedDate = content.itemTheatricalString
        if content.itemContentMedia == .tvShow {
            item.upcomingSeason = content.hasUpcomingSeason
            item.nextSeasonNumber = Int64(content.nextEpisodeToAir?.seasonNumber ?? 0)
        }
        try? viewContext.save()
    }
    
    func save(_ person: Person) {
        let viewContext = container.viewContext
        let item = PersonItem(context: viewContext)
        item.name = person.name
        item.id = Int64(person.id)
        item.image = person.personImage
        try? viewContext.save()
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
    
    func fetch(person id: PersonItem.ID) -> PersonItem? {
        let context = container.viewContext
        let request: NSFetchRequest<PersonItem> = PersonItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        let item = try? context.fetch(request)
        if let item {
            return item[0]
        }
        return nil
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
    
    // Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent, isWatched watched: Bool? = nil, isFavorite favorite: Bool? = nil) {
        if isItemSaved(id: content.id, type: content.itemContentMedia) {
            let viewContext = container.viewContext
            let item = self.fetch(for: WatchlistItem.ID(content.id))
            if let item {
                item.title = content.itemTitle
                item.image = content.cardImageMedium
                item.schedule = content.itemStatus.scheduleNumber
                item.notify = content.itemCanNotify
                item.formattedDate = content.itemTheatricalString
                if content.itemContentMedia == .tvShow {
                    item.upcomingSeason = content.hasUpcomingSeason
                    item.nextSeasonNumber = Int64(content.nextEpisodeToAir?.seasonNumber ?? 0)
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
    func delete(_ item: WatchlistItem) {
        let viewContext = container.viewContext
        let item = try? viewContext.existingObject(with: item.objectID)
        if let item {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
    
    func delete(_ item: PersonItem) {
        let viewContext = container.viewContext
        let person = try? viewContext.existingObject(with: item.objectID)
        if let person {
            viewContext.delete(person)
            try? viewContext.save()
        }
    }
    
    //MARK: Data properties.
    
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
    
    func isPersonSaved(id: Person.ID) -> Bool {
        let context = container.viewContext
        let request: NSFetchRequest<PersonItem> = PersonItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", PersonItem.ID(id))
        let numberOfObjects = try? context.count(for: request)
        if let numberOfObjects {
            if numberOfObjects > 0 { return true }
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
    
}
