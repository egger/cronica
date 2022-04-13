//
//  WatchlistController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//  swiftlint:disable trailing_whitespace

import CoreData
import SwiftUI
import TelemetryClient

/// An environment singleton responsible for managing Watchlist Core Data stack, including handling saving,
/// counting fetch request, tracking watchlists, and dealing with sample data.
class WatchlistController: ObservableObject {
    static let shared = WatchlistController()
    static var preview: WatchlistController = {
        let result = WatchlistController(inMemory: true)
        let viewContext = result.container.viewContext
        for item in Content.previewContents {
            let newItem = WatchlistItem(context: viewContext)
            newItem.title = item.itemTitle
            newItem.id = Int64(item.id)
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
                TelemetryManager.send("WatchlistController_initError", with: ["Error:":"\(error.localizedDescription)"])
            }
        }
    }
    
    /// Adds or update an item to Watchlist Core Data.
    /// - Parameter content: The item to be added, or updated.
    func saveItem(content: Content, notify: Bool) {
        let viewContext = WatchlistController.shared.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.contentType = Int64(content.itemContentMedia.watchlistInt)
        item.title = content.itemTitle
        item.id = Int64(content.id)
        item.image = content.cardImageMedium
        item.poster = content.posterImageMedium
        item.status = content.itemStatus
        item.notify = notify
        do {
            try viewContext.save()
        } catch {
            TelemetryManager.send("WatchlistController_saveItemError", with: ["Error:":"\(error.localizedDescription)"])
        }
    }
    
    func updateItem(content: Content) {
        if isItemInList(id: content.id) {
            let viewContext = WatchlistController.shared
            do {
                let item = try viewContext.getItem(id: WatchlistItem.ID(content.id))
                item.title = content.itemTitle
                item.image = content.cardImageMedium
                item.poster = content.posterImageMedium
                item.status = content.itemStatus
                let notify = WatchlistController.itemCanNotify(item: content)
                item.notify = notify
                try viewContext.container.viewContext.save()
                print("\(content.itemTitle) is up to date.")
                print("\(item.itemTitle) can still notify: \(notify)")
            } catch {
                TelemetryManager.send("WatchlistController_updateItemError", with: ["Error:":"\(error.localizedDescription)"])
            }
        }
    }
    
    static func itemCanNotify(item: Content) -> Bool {
        if let date = item.itemTheatricalDate {
            if date > Date() {
                return true
            }
        }
        if let date = item.nextEpisodeDate {
            if date > Date() {
                return true
            }
        }
        return false
    }
    
    /// Deletes a WatchlistItem from Core Data.
    /// - Parameter id: Use a WatchlistItem to search its' existence in Core Data, and then delete it.
    func removeItem(id: WatchlistItem) throws {
        let viewContext = WatchlistController.shared.container.viewContext
        do {
            let item = try viewContext.existingObject(with: id.objectID)
            viewContext.delete(item)
            try viewContext.save()
        } catch {
            TelemetryManager.send("WatchlistController_removeItemError", with: ["Error:":"\(error.localizedDescription)"])
        }
    }
    
    /// Search if an item is added to the list.
    /// - Parameter id: The ID used to fetch Watchlist list.
    /// - Returns: Returns true if the content is already added to the Watchlist.
    func isItemInList(id: Content.ID) -> Bool {
        let viewContext = WatchlistController.shared.container.viewContext
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
            TelemetryManager.send("WatchlistController_isItemInListError", with: ["Error:":"\(error.localizedDescription)"])
            fatalError(error.localizedDescription)
        }
    }
    
    func isNotificationScheduled(id: Content.ID) -> Bool {
        let item = try? getItem(id: WatchlistItem.ID(id))
        if let item = item {
            if item.notify { return true }
        }
        return false
    }
    
    /// Get an item from the Watchlist.
    /// - Parameter id: The ID used to fetch the list.
    /// - Returns: If the item is in the list, it will return it.
    func getItem(id: WatchlistItem.ID) throws -> WatchlistItem {
        let viewContext = WatchlistController.shared.container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", WatchlistItem.ID(id))
        do {
            let item = try viewContext.fetch(request)
            return item[0]
        } catch {
            TelemetryManager.send("WatchlistController_getItemError", with: ["Error:":"\(error.localizedDescription)"])
            fatalError(error.localizedDescription)
        }
    }
}
