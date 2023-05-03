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
    
    func updateListTitle(of list: CustomList, with title: String) {
        do {
            list.title = title
            try save()
        } catch {
            
        }
    }
    
    func updateListNotes(of list: CustomList, with notes: String) {
        do {
            list.notes = notes
            try save()
        } catch {
            
        }
    }
    
    /// Remove a set of items from a CustomList.
    /// - Parameters:
    ///   - list: The CustomList that will have items removed from.
    ///   - items: The WatchlistItems to be removed from the given list.
    func removeItemsFromList(of list: CustomList, with items: Set<WatchlistItem>) {
        do {
            var set = list.itemsSet
            for item in set {
                if items.contains(item) {
                    set.remove(item)
                }
            }
            list.items = set as NSSet
            try save()
        } catch {
            
        }
    }
    
    func createList(title: String, description: String, items: Set<WatchlistItem>, idOnTMDb: Int? = nil) -> CustomList? {
        do {
            let viewContext = container.viewContext
            let list = CustomList(context: viewContext)
            list.id = UUID()
            list.title = title
            if let idOnTMDb {
                list.isSyncEnabledTMDB = true
                list.idOnTMDb = Int64(idOnTMDb)
            }
            list.creationDate = Date()
            list.updatedDate = Date()
            list.notes = description
            list.items = items as NSSet
            try save()
            return list
        } catch {
            return nil
        }
    }
}
