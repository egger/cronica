//
//  DataController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import SwiftUI

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// counting fetch request, tracking watchlists, and dealing with sample data.
class DataController: ObservableObject {
    static let shared = DataController()
    static var preview: DataController = {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
        for item in Content.previewContents {
            let newItem = WatchlistItem(context: viewContext)
            newItem.title = item.itemTitle
            newItem.id = Int32(item.id)
            newItem.image = item.cardImageMedium
            newItem.poster = item.posterImageMedium
            newItem.type = "Movie"
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
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores {_, error in
            if let error = error {
                fatalError("Fatal error loading storage, error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Adds a new item to Watchlist Core Data.
    func saveItem(content: Content, type: Int, notify: Bool = false) {
        let viewContext = DataController.shared.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = content.itemTitle
        item.id = Int32(content.id)
        item.image = content.cardImageMedium
        item.poster = content.posterImageMedium
        item.status = content.itemStatus
        item.notify = notify
        item.contentType = Int16(type)
        do {
            try viewContext.save()
        } catch {
            fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
        }
    }
    
    func updateItem(item: WatchlistItem, update: Content, notify: Bool) {
        do {
            let item = try self.getItem(id: WatchlistItem.ID(update.id))
            item.image = update.cardImageMedium
            item.poster = update.posterImageMedium
            item.status = update.itemStatus
            item.notify = notify
            try DataController.shared.container.viewContext.save()
        } catch {
            fatalError("Fatal error on updating a new item, error: \(error.localizedDescription).")
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    /// - Parameter id: Use a WatchlistItem to search its' existence in Core Data, and then delete it.
    func removeItem(id: WatchlistItem) throws {
        let viewContext = DataController.shared.container.viewContext
        do {
            let item = try viewContext.existingObject(with: id.objectID)
            viewContext.delete(item)
            try viewContext.save()
        } catch {
            fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
        }
    }
    
    /// Search if an item is added to the list.
    /// - Parameter id: The ID used to fetch Watchlist list.
    /// - Returns: Returns true if the content is already added to the Watchlist.
    func isItemInList(id: Content.ID) -> Bool {
        let viewContext = DataController.shared.container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", WatchlistItem.ID(id))
        do {
            let numberOfObjects = try viewContext.count(for: request)
            if numberOfObjects > 0 {
                return true
            } else {
                return false
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func isNotificationScheduled(id: Content.ID) -> Bool {
        do {
            let item = try getItem(id: WatchlistItem.ID(id))
            if item.notify {
                return true
            } else {
                return false
            }
        } catch {
            
        }
        return false
    }
    
    /// Get an item from the Watchlist.
    /// - Parameter id: The ID used to fetch the list.
    /// - Returns: If the item is in the list, it will return it.
    func getItem(id: WatchlistItem.ID) throws -> WatchlistItem {
        let viewContext = DataController.shared.container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", WatchlistItem.ID(id))
        do {
            let item = try viewContext.fetch(request)
            return item[0]
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
