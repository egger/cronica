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
    var persistence: PersistenceController!
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        persistence = PersistenceController(inMemory: true)
        managedObjectContext = persistence.container.viewContext
    }
    
    func testAddToWatchlist() {
        for item in ItemContent.previewContents {
            persistence.saveItem(content: item, notify: false)
        }
        for item in ItemContent.previewContents {
            XCTAssertTrue(persistence.isItemInList(id: item.id, type: .movie))
        }
    }
    
//    func testRemoveFromWatchlist() {
//        XCTAssertNoThrow({
//            let item = try self.dataController.getItem(id: WatchlistItem.ID(ItemContent.previewContent.id))
//            try self.dataController.removeItem(id: item)
//        })
//    }
}
