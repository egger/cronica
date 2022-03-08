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
        for item in Content.previewContents {
            dataController.saveItem(content: item, type: MediaType.movie.watchlistInt, notify: Bool.random())
        }
        do {
            try managedObjectContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func testIsItemInList() {
        XCTAssert(dataController.isItemInList(id: Content.previewContent.id))
    }
    
    func testRemoveFromWatchlist() {
        do {
            let item = try dataController.getItem(id: WatchlistItem.ID(Content.previewContent.id))
            try dataController.removeItem(id: item)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
