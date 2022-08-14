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
            persistence.save(item)
        }
        for item in ItemContent.previewContents {
            XCTAssertTrue(persistence.isItemSaved(id: item.id, type: item.itemContentMedia))
        }
    }
}
