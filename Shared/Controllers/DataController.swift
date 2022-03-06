//
//  DataController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

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
            newItem.image = item.cardImage
            newItem.notify = Bool.random()
            newItem.type = "Movie"
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return result
    }()
    
    /// The lone CloudKit container used to store all our data.
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
        container.loadPersistentStores {_, error in
            if let error = error {
                fatalError("Fatal error loading storage, error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Adds a new item to Watchlist Core Data.
    func saveItem(content: Content, type: Int, notify: Bool) {
        let viewContext = DataController.shared.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = content.itemTitle
        item.id = Int32(content.id)
        item.image = content.cardImage
        item.status = content.itemStatus
        item.contentType = Int16(type)
        item.notify = notify
        do {
            try viewContext.save()
        } catch {
            fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    /// - Parameter id: Use a WatchlistItem to search its' existence in Core Data, and then delete it.
    func removeItem(id: WatchlistItem) throws {
        let viewContext = DataController.shared.container.viewContext
        do {
            let item = try viewContext.existingObject(with: id.objectID)
            viewContext.delete(item)
        } catch {
            fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
        }
    }
}
