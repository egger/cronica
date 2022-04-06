//
//  WatchlistItem-CoreDataHelpers.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import Foundation
import CoreData

extension WatchlistItem {
    var itemTitle: String {
        title ?? NSLocalizedString("No title available",
                                   comment: "Title couldn't be found.")
    }
    var itemId: Int {
        Int(id)
    }
    var itemMedia: MediaType {
        switch contentType {
        case 0: return .movie
        case 1: return .tvShow
        case 2: return .person
        default: return .movie
        }
    }
    static var example: WatchlistItem {
        let controller = WatchlistController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = Content.previewContent.itemTitle
        item.id = Int32(Content.previewContent.id)
        item.image = Content.previewContent.cardImageMedium
        item.contentType = 0
        item.notify = false
        return item
    }
}
