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
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    
    func registerRefreshBGTask() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier,
//                                        using: DispatchQueue.global(qos: .background)) { (task) in
//            self.handleAppRefresh(task: task as! BGAppRefreshTask)
//            TelemetryManager.send("registerRefreshBGTask", with: ["isBGTaskScheduled":"true"])
//        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1440 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("scheduleAppRefreshBGTask")
            TelemetryManager.send("scheduleAppRefreshBGTask")
        } catch {
            TelemetryManager.send("scheduleAppRefreshBGTaskError",
                                  with: ["Error:":"\(error.localizedDescription)"])
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let background = BackgroundManager()
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            background.handleAppRefreshContent()
            TelemetryManager.send("handleAppRefreshBGTask", with: ["isOperationAdded":"true"])
        }
        task.setTaskCompleted(success: true)
        TelemetryManager.send("handleAppRefreshBGTask", with: ["isFinished":"true"])
    }
    
    func handleAppRefreshContent() {
        let items = self.fetchWatchlistItems()
        Task {
            await self.fetchUpdates(items: items)
        }
    }
    
    private func fetchWatchlistItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let notifyPredicate = NSPredicate(format: "notify == %d", true)
        let orPredicate = NSCompoundPredicate(type: .or,
                                              subpredicates: [notifyPredicate])
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
                self.context.updateItem(content: content, isWatched: nil, isFavorite: nil)
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
