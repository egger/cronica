//
//  StoryTests.swift
//  StoryTests
//
//  Created by Alexandre Madeira on 06/02/22.
//

import XCTest
import CoreData
@testable import Story

class StoryTests: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
    
    func testAddToWatchlist() {
        for item in Movie.previewMovies {
            let newItem = MovieItem(context: managedObjectContext)
            newItem.title = item.title
            newItem.id = Int32(item.id)
            newItem.image = item.backdropImage
            newItem.notify = Bool.random()
        }
        do {
            try managedObjectContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
