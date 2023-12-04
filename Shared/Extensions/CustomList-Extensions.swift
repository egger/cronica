//
//  CustomList-Extensions.swift
//  Cronica
//
//  Created by Alexandre Madeira on 13/02/23.
//

import Foundation

extension CustomList {
    var itemTitle: String {
        return title ?? NSLocalizedString("Untitled List", comment: "")
    }
    var itemLastUpdateFormatted: String {
        if let updatedDate {
            return updatedDate.convertDateToString()
        }
        return ""
    }
    var itemGlanceInfo: String {
        if let notes {
            if !notes.isEmpty {
                return notes
            }
        }
        if let items {
            return NSLocalizedString("\(items.count) item", comment: "")
//            let formatString = NSLocalizedString("items count", comment: "")
//            let result = String(format: formatString, items.count)
//            return result
        }
        return String()
    }
    var itemCount: String {
        if let items {
            return NSLocalizedString("\(items.count) item", comment: "")
//            let formatString = NSLocalizedString("items count", comment: "")
//            let result = String(format: formatString, items.count)
//            return result
        }
        return NSLocalizedString("Empty", comment: "")
    }
    var itemFooter: String {
        if let notes {
            if !notes.isEmpty {
                return notes
            }
        }
        return itemLastUpdateFormatted
    }
    var itemsSet: Set<WatchlistItem> {
        return items as? Set<WatchlistItem> ?? []
    }
    var itemsArray: [WatchlistItem] {
        let set = items as? Set<WatchlistItem> ?? []
        return set.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
    var itemIDToString: String {
        guard let id else { return String() }
        return id.uuidString
    }
}
