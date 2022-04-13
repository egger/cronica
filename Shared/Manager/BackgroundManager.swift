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
    private static let context = WatchlistController.shared
    private static let network = NetworkService.shared
    private static let notifications = NotificationManager.shared
    
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
            let list = try BackgroundManager.context.container.viewContext.fetch(request)
            return list
        } catch {
            TelemetryManager.send("fetchWatchlistItemsError", with: ["Error:":"\(error.localizedDescription)"])
            TelemetryManager.send("\(error.localizedDescription).")
        }
        return []
    }
    
    private func fetchUpdates(items: [WatchlistItem]) async {
        for item in items {
            do {
                let content = try await BackgroundManager.network.fetchContent(id: item.itemId, type: item.itemMedia)
                BackgroundManager.context.updateItem(content: content)
                if content.itemCanNotify {
                    let identifier: String = "\(content.itemTitle)+\(content.id)"
                    var title: String
                    var body: String
                    if content.itemContentMedia == .movie {
                        title = content.itemTitle
                        body = "The movie '\(content.itemTitle)' is out now!"
                    } else {
                        title = "New Episode."
                        body = "The next episode of '\(content.itemTitle)' is out now!"
                    }
                    var date: Date
                    if content.itemContentMedia == .movie {
                        date = content.itemTheatricalDate!
                    } else if content.itemContentMedia == .tvShow {
                        date = content.nextEpisodeDate!
                    } else {
                        date = Date()
                    }
                    BackgroundManager.notifications.scheduleNotification(identifier: identifier,
                                                       title: title,
                                                       body: body,
                                                       date: date)
                    TelemetryManager.send("fetchUpdates")
                }
            } catch {
                TelemetryManager.send("fetchUpdatesError", with: ["Error:":"\(error.localizedDescription)"])
            }
        }
    }
}
