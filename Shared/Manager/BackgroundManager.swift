//
//  BackgroundManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/04/22.
//

import Foundation
import CoreData
import BackgroundTasks

struct BackgroundManager {
    static let shared = BackgroundManager()
    private let context = PersistenceController.shared
    private let network = NetworkService.shared
    private let notifications = NotificationManager.shared
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    private let backgroundProcessingIdentifier = "dev.alexandremadeira.cronica.backgroundProcessingTask"
    
#if os(iOS) || os(tvOS)
    func registerRefreshBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as? BGAppRefreshTask ?? nil)
        }
    }
    
    func registerAppMaintenanceBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundProcessingIdentifier, using: nil) { task in
            self.handleAppMaintenance(task: task as? BGProcessingTask ?? nil)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 360 * 60) // Fetch no earlier than 6 hours from now
        try? BGTaskScheduler.shared.submit(request)
    }
    
    private func scheduleAppMaintenance() {
        let request = BGProcessingTaskRequest(identifier: backgroundProcessingIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        let oneWeek = TimeInterval(7 * 24 * 60 * 60)
        request.earliestBeginDate = Date(timeIntervalSinceNow: oneWeek)
        do {
            try BGTaskScheduler.shared.submit(request)
#if DEBUG
            print("Scheduled App Maintenance.")
#endif
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "BackgroundManager.scheduleAppMaintenance()")
        }
    }
    
    // Fetch the latest updates from api.
    private func handleAppRefresh(task: BGAppRefreshTask?) {
        guard let task else { return }
        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let background = BackgroundManager()
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }
        queue.addOperation {
            Task {
                await background.handleAppRefreshContent()
            }
        }
        task.setTaskCompleted(success: true)
        CronicaTelemetry.shared.handleMessage("identifier: \(task.identifier)",
                                              for: "BackgroundManager.handleAppRefreshBGTask")
    }
    
    private func handleAppMaintenance(task: BGProcessingTask?) {
        guard let task else { return }
        scheduleAppMaintenance()
        let queue = OperationQueue()
        let background = BackgroundManager()
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            Task {
                await background.handleAppRefreshMaintenance(isAppMaintenance: true)
            }
        }
        task.setTaskCompleted(success: true)
        CronicaTelemetry.shared.handleMessage("identifier: \(task.identifier)",
                                              for: "BackgroundManager.handleAppMaintenance")
    }
#endif
    
    func handleAppRefreshContent() async {
        let items = self.fetchItems()
        await self.fetchUpdates(items: items)
    }
    
    func handleAppRefreshMaintenance(isAppMaintenance: Bool = false) async {
        let items = self.fetchReleasedItems()
        await self.fetchUpdates(items: items)
        if isAppMaintenance {
            CronicaTelemetry.shared.handleMessage("App Maintenance done.",
                                                  for: "BackgroundManager.handleAppRefreshMaintenance()")
        }
    }
    
    /// Fetch for any Watchlist item that match notify, soon, or tv predicates.
    /// - Returns: Returns a list of Watchlist items that matched the predicates.
    private func fetchItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let notifyPredicate = NSPredicate(format: "notify == %d", true)
        let soonPredicate = NSPredicate(format: "schedule == %d", ItemSchedule.soon.toInt)
        let renewedPredicate = NSPredicate(format: "schedule == %d", ItemSchedule.renewed.toInt)
        let productionPredicate = NSPredicate(format: "schedule == %d", ItemSchedule.production.toInt)
        let orPredicate = NSCompoundPredicate(type: .or,
                                              subpredicates: [notifyPredicate,
                                                              productionPredicate,
                                                              soonPredicate,
                                                              renewedPredicate])
        request.predicate = orPredicate
        do {
            let list = try self.context.container.viewContext.fetch(request)
            return list
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "BackgroundManager.fetchItems()")
            return []
        }
    }
    
    private func fetchReleasedItems() -> [WatchlistItem] {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let releasedPredicate = NSPredicate(format: "schedule == %d", ItemSchedule.released.toInt)
        request.predicate = NSCompoundPredicate(type: .or,
                                                subpredicates: [releasedPredicate])
        let list = try? self.context.container.viewContext.fetch(request)
        return list ?? []
    }
    
    /// Updates every item in the items array, update it in CoreData if needed, and update notification schedule.
    private func fetchUpdates(items: [WatchlistItem]) async {
        if !items.isEmpty {
            for item in items {
                let content = try? await self.network.fetchItem(id: item.itemId, type: item.itemMedia)
                if let content {
                    if content.itemCanNotify {
                        // If fetched item release date is different than the scheduled one,
                        // then remove the old date and register the new one.
                        if self.compareDates(original: item.itemDate, new: content.itemFallbackDate) {
                            self.notifications.removeNotification(identifier: content.itemNotificationID)
                        }
                        if content.itemStatus == .cancelled {
                            notifications.removeNotification(identifier: content.itemNotificationID)
                        } else {
                            self.notifications.schedule(notificationContent: content)
                        }
                    }
                    self.context.update(item: content)
                }
            }
        }
    }
    
    /// Compares two dates and returns a bool if the dates are different.
    private func compareDates(original: Date?, new: Date?) -> Bool {
        if let original {
            if let new {
                if original != new {
                    return true
                }
            }
        }
        return false
    }
}

