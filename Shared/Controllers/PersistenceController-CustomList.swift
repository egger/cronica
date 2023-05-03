//
//  PersistenceController-CustomList.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import Foundation

extension PersistenceController {
    func delete(_ list: CustomList) {
        let viewContext = container.viewContext
        do {
            let item = try viewContext.existingObject(with: list.objectID)
            viewContext.delete(item)
            try save()
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "PersistenceController.delete")
        }
    }
    
    func updateList(for id: WatchlistItem.ID, type: MediaType, to list: CustomList) {
        do {
            let contentID = "\(id)@\(type.toInt)"
            let item = try fetch(for: contentID)
            guard let item else { return }
            if item.itemLists.contains(list) {
                var original = item.itemLists
                original.remove(list)
                let converted = original as NSSet
                item.list = converted
                try save()
            } else {
                var set = Set<CustomList>()
                set.insert(list)
                let original = item.itemLists
                for item in original {
                    set.insert(item)
                }
                let converted = set as NSSet
                item.list = converted
                try save()
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "PersistenceController.updateList")
        }
    }
    
    func fetchLists(for id: Int, type: MediaType) -> [CustomList] {
        do {
            let contentID = "\(id)@\(type.toInt)"
            let item = try fetch(for: contentID)
            guard let item else { return [] }
            return item.listsArray
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "fetchLists")
            return []
        }
    }
    
    func updateListInformation(list: CustomList, title: String? = nil, description: String? = nil, items: [WatchlistItem]? = nil) {
        if let title {
            if title != list.title {
                list.title = title
            }
        }
        if let description {
            if description != list.notes {
                list.notes = description
            }
        }
        if let items {
            var set = list.itemsSet
            for item in set {
                if items.contains(item) {
                    set.remove(item)
                }
            }
            list.items = set as NSSet
        }
        try? save()
    }
}
