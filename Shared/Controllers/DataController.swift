//
//  DataController.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import CoreData
import SwiftUI

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch request, tracking watchlists, and dealing with sample data.
class DataController: ObservableObject {
    static let shared = DataController()
    
    static var preview: DataController = {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
        for item in Movie.previewMovies {
            let newItem = MovieItem(context: viewContext)
            newItem.title = item.title
            newItem.id = Int32(item.id)
            newItem.image = item.backdropImage
            newItem.notify = Bool.random()
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
}
