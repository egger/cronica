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
        for item in ItemContent.previewContents {
            persistence.save(item)
        }
        for item in ItemContent.previewContents {
            XCTAssertTrue(persistence.isItemSaved(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testMarkAsWatched() {
        for item in ItemContent.previewContents {
            persistence.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: true, favorite: nil)
        }
        for item in ItemContent.previewContents {
            XCTAssertTrue(persistence.isMarkedAsWatched(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testRemoveFromWatched() {
        for item in ItemContent.previewContents {
            persistence.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: false, favorite: nil)
        }
        for item in ItemContent.previewContents {
            XCTAssertFalse(persistence.isMarkedAsWatched(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testMarkAsFavorite() {
        for item in ItemContent.previewContents {
            persistence.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: nil, favorite: true)
        }
        for item in ItemContent.previewContents {
            XCTAssertTrue(persistence.isMarkedAsFavorite(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testRemoveFromFavorite() {
        for item in ItemContent.previewContents {
            persistence.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: nil, favorite: false)
        }
        for item in ItemContent.previewContents {
            XCTAssertFalse(persistence.isMarkedAsFavorite(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testMarkAsArchive() {
        for item in ItemContent.previewContents {
            let watchlistItem: Set<String> = [item.itemNotificationID]
            persistence.updateArchive(items: watchlistItem)
            XCTAssertTrue(persistence.isItemArchived(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testRemoveFromArchive() {
        for item in ItemContent.previewContents {
            let watchlistItem: Set<String> = [item.itemNotificationID]
            persistence.updateArchive(items: watchlistItem)
            XCTAssertFalse(persistence.isItemArchived(id: item.id, type: item.itemContentMedia))
        }
    }
    
    func testRemoveItemsFromWatchlist() {
        for item in ItemContent.previewContents {
            let watchlistItem = try? persistence.fetch(for: Int64(item.id), media: item.itemContentMedia)
            guard let watchlistItem else { return }
            persistence.delete(watchlistItem)
        }
        for item in ItemContent.previewContents {
            XCTAssertFalse(persistence.isItemSaved(id: item.id, type: item.itemContentMedia))
        }
    }
    
}
