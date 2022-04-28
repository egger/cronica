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
            dataController.saveItem(content: item, notify: false)
        }
        for item in Content.previewContents {
            XCTAssertTrue(dataController.isItemInList(id: item.id))
        }
    }
    
    func testRemoveFromWatchlist() {
        XCTAssertNoThrow({
            let item = try self.dataController.getItem(id: WatchlistItem.ID(Content.previewContent.id))
            try self.dataController.removeItem(id: item)
        })
    }
}
