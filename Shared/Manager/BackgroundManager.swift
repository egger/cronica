//
//  BackgroundManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/04/22.
//

import Foundation
import CoreData
import TelemetryClient

class BackgroundManager {
    private let context = WatchlistController.shared
    private let network = NetworkService.shared
    private let notifications = NotificationManager.shared
    
    func handleAppRefreshContent() {
        let items = self.fetchWatchlistItems()
        Task {
            await self.fetchUpdates(items: items)
            TelemetryManager.send("handleAppRefreshContent")
        }
    }
    
    private func fetchWatchlistItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let notifyPredicate = NSPredicate(format: "notify == %d", true)
        let returningPredicate = NSPredicate(format: "status == %@", "Returning Series")
        let orPredicate = NSCompoundPredicate(type: .or,
                                              subpredicates: [notifyPredicate, returningPredicate])
        request.predicate = orPredicate
        do {
            let list = try self.context.container.viewContext.fetch(request)
            return list
        } catch {
            TelemetryManager.send("fetchWatchlistItemsError",
                                  with: ["Error:":"\(error.localizedDescription)"])
        }
        return []
    }
    
    private func fetchUpdates(items: [WatchlistItem]) async {
        for item in items {
            do {
                let content = try await self.network.fetchContent(id: item.itemId, type: item.itemMedia)
                self.context.updateItem(content: content)
                if content.itemCanNotify {
                    self.notifications.schedule(content: content)
                    TelemetryManager.send("fetchUpdates")
                }
            } catch {
                TelemetryManager.send("fetchUpdatesError",
                                      with: ["Error:":"\(error.localizedDescription)"])
            }
        }
    }
}
