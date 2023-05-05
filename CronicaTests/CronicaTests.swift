//
//  CronicaTests.swift
//  CronicaTests
//
//  Created by Alexandre Madeira on 06/04/23.
//

import XCTest
import CoreData
@testable import Cronica

final class CronicaTests: XCTestCase {
    var persistence: PersistenceController!
    var managedContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        persistence = PersistenceController(inMemory: true)
        managedContext = persistence.container.viewContext
    }
    
    func testAddItemsToWatchlist() {
        for item in ItemContent.examples {
            persistence.save(item)
        }
        for item in ItemContent.examples {
            XCTAssertTrue(persistence.isItemSaved(id: item.itemNotificationID))
        }
    }
    
    func testMarkAsWatched() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateWatched(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertTrue(persistence.isMarkedAsWatched(id: item.itemNotificationID))
        }
    }
    
    func testRemoveFromWatched() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateWatched(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertFalse(persistence.isMarkedAsWatched(id: item.itemNotificationID))
        }
    }
    
    func testMarkAsFavorite() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateFavorite(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertTrue(persistence.isMarkedAsFavorite(id: item.itemNotificationID))
        }
    }
    
    func testRemoveFromFavorite() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateFavorite(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertFalse(persistence.isMarkedAsFavorite(id: item.itemNotificationID))
        }
    }
    
    func testMarkAsArchive() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateArchive(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertTrue(persistence.isItemArchived(id: item.itemNotificationID))
        }
    }
    
    func testRemoveFromArchive() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updateArchive(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertFalse(persistence.isItemArchived(id: item.itemNotificationID))
        }
    }
    
    func testMarkAsPin() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updatePin(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertTrue(persistence.isItemPinned(id: item.itemNotificationID))
        }
    }
    
    func testRemoveFromPins() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.updatePin(for: item)
        }
        for item in ItemContent.examples {
            XCTAssertFalse(persistence.isItemPinned(id: item.itemNotificationID))
        }
    }
    
    func testRemoveItemsFromWatchlist() {
        for item in ItemContent.examples {
            guard let item = try? persistence.fetch(for: item.itemNotificationID) else { return }
            persistence.delete(item)
        }
        for item in ItemContent.examples {
            XCTAssertFalse(persistence.isItemSaved(id: item.itemNotificationID))
        }
    }
    
}
