//
//  BackgroundManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/04/22.
//

import Foundation
import CoreData
import BackgroundTasks

class BackgroundManager {
    private let context = DataController.shared
    private let network = NetworkService.shared
    private let notifications = NotificationManager.shared
    
    func handleAppRefreshContent() {
        let items = self.fetchWatchlistItems()
        Task {
            await self.fetchUpdates(items: items)
        }
    }
    
    /// Fetch for any Watchlist item that match notify, soon, or tv predicates.
    /// - Returns: Returns a list of Watchlist items that matched the predicates.
    private func fetchWatchlistItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let notifyPredicate = NSPredicate(format: "notify == %d", true)
        let soonPredicate = NSPredicate(format: "schedule == %d", ItemSchedule.soon.scheduleNumber)
        let tvPredicate = NSPredicate(format: "contentType == %d", MediaType.tvShow.watchlistInt)
        let orPredicate = NSCompoundPredicate(type: .or,
                                              subpredicates: [notifyPredicate, soonPredicate, tvPredicate])
        request.predicate = orPredicate
        let list = try? self.context.container.viewContext.fetch(request)
        if let list {
            return list
        }
        return []
    }
    
    /// Updates every item in the items array, update it in CoreData if needed, and update notification schedule.
    private func fetchUpdates(items: [WatchlistItem]) async {
        for item in items {
            let content = try? await self.network.fetchContent(id: item.itemId, type: item.itemMedia)
            if let content {
                self.context.updateItem(content: content, isWatched: nil, isFavorite: nil)
                if content.itemCanNotify {
                    self.notifications.schedule(notificationContent: content)
                }
            }
        }
    }
}

