//
//  BackgroundManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/04/22.
//

import Foundation
import CoreData
import TelemetryClient
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
    
    private func fetchWatchlistItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let notifyPredicate = NSPredicate(format: "notify == %d", true)
        let soonPredicate = NSPredicate(format: "schedule == %d", ContentSchedule.soon.scheduleNumber)
        let tvPredicate = NSPredicate(format: "contentType == %d", MediaType.tvShow.watchlistInt)
        let orPredicate = NSCompoundPredicate(type: .or,
                                              subpredicates: [notifyPredicate, soonPredicate, tvPredicate])
        request.predicate = orPredicate
        do {
            let list = try self.context.container.viewContext.fetch(request)
            return list
        } catch {
            TelemetryManager.send("BackgroundManager_fetchWatchlistItems",
                                  with: ["Error":"\(error.localizedDescription)."])
        }
        return []
    }
    
    private func fetchUpdates(items: [WatchlistItem]) async {
        for item in items {
            do {
                let content = try await self.network.fetchContent(id: item.itemId, type: item.itemMedia)
                self.context.updateItem(content: content, isWatched: nil, isFavorite: nil)
                if content.itemCanNotify {
                    self.notifications.schedule(content: content)
                }
            } catch {
                TelemetryManager.send("BackgroundManager_fetchUpdates",
                                      with: ["Error":"\(error.localizedDescription)."])
            }
        }
    }
}

