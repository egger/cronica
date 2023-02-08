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
    private let context = PersistenceController.shared.container.newBackgroundContext()
    private let network = NetworkService.shared
    private let notifications = NotificationManager.shared
    private static let lastMaintenanceKey = "lastMaintenance"
    static let shared = BackgroundManager()
    
    var lastMaintenance: Date? {
        get {
            return UserDefaults.standard.object(forKey: BackgroundManager.lastMaintenanceKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: BackgroundManager.lastMaintenanceKey)
        }
    }
    
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
            let list = try context.fetch(request)
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
        let archivePredicate = NSPredicate(format: "isArchive == %d", true)
        request.predicate = NSCompoundPredicate(type: .or,
                                                subpredicates: [releasedPredicate, archivePredicate])
        do {
            let list = try self.context.fetch(request)
            return list
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "BackgroundManager.fetchReleasedItems()")
            return []
        }
    }
    
    /// Updates every item in the items array, update it in CoreData if needed, and update notification schedule.
    private func fetchUpdates(items: [WatchlistItem]) async {
        if !items.isEmpty {
            for item in items {
                // if the item is already released, archive or watched
                // the need for constant updates are not there.
                // So, to save resources, they will update less frequently.
                if item.isMovie && item.isReleased || item.isArchive || item.isWatched {
                    if item.lastValuesUpdated.hasPassedOneWeek() {
                        await update(item)
                    }
                } else if item.isTvShow && !item.isArchive {
                    await update(item)
                } else {
                    await update(item)
                }
            }
        }
    }
    
    private func update(_ item: WatchlistItem) async {
        do {
            let content = try await self.network.fetchItem(id: item.itemId, type: item.itemMedia)
            if content.itemCanNotify && item.shouldNotify {
                // If fetched item release date is different than the scheduled one,
                // then remove the old date and register the new one.
                if item.itemDate.areDifferentDates(with: content.itemFallbackDate) {
                    notifications.removeNotification(identifier: content.itemNotificationID)
                }
                if content.itemStatus == .cancelled {
                    notifications.removeNotification(identifier: content.itemNotificationID)
                }
                // In order to avoid passing the limit of local notifications,
                // the app will only register when it's less than two months away
                // from release date.
                if content.itemFallbackDate.isLessThanTwoMonthsAway() {
                    notifications.schedule(content)
                }
            }
            PersistenceController.shared.update(item: content)
        } catch {
            if Task.isCancelled { return }
            let message = "Could not update, error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "BackgroundManager.update()")
        }
        
    }
}
