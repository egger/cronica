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
                                                  for: "BackgroundManager.fetchItems.failed")
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
                                                  for: "BackgroundManager.fetchReleasedItems.failed")
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
        if item.id == 0 { return }
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
            if !item.isArchive && item.isWatching && !item.displayOnUpNext && item.isTvShow {
                await self.fetchNextEpisodeUpNext(for: item)
            }
        } catch {
            if Task.isCancelled { return }
            let message = "Could not update item: \(item.notificationID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "BackgroundManager.update.failed")
        }
    }
    
    private func fetchNextEpisodeUpNext(for show: WatchlistItem) async {
        do {
            guard let watchedEpisodes = show.watchedEpisodes else { return }
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: show.itemId, season: Int(show.seasonNumberUpNext))
            guard let episodes = season.episodes else { return }
            var nextEpisode: Episode?
            if episodes.count <= Int(show.nextEpisodeNumber) {
                // In an array, the first item is always numbered as 0. So, if the next episode is numbered as 8, we need to subtract 1 from the episode list to get the correct index value for the next episode. This is because the app always saves the next episode number as the one immediately after the one the user has watched. For example, if the user has watched episode 7, the app will save the next episode number as 8.
                nextEpisode = episodes[Int(show.nextEpisodeNumber - 1)]
                if let nextEpisode {
                    let episodeId = nextEpisode.id
                    if !watchedEpisodes.contains("\(episodeId)") && nextEpisode.isItemReleased {
                        show.displayOnUpNext = true
                    }
                }
                
            } else {
                let nextSeason = try await network.fetchSeason(id: show.itemId, season: Int(show.seasonNumberUpNext + 1))
                if let nextSeasonEpisodes = nextSeason.episodes {
                    nextEpisode = nextSeasonEpisodes.first
                    guard let nextEpisode else { return }
                    let episodeId = nextEpisode.id
                    if !watchedEpisodes.contains("\(episodeId)") && nextEpisode.isItemReleased {
                        show.seasonNumberUpNext = Int64(nextEpisode.itemSeasonNumber)
                        show.nextEpisodeNumberUpNext = Int64(nextEpisode.itemEpisodeNumber)
                        show.displayOnUpNext = true
                    }
                }
            }
           
            if context.hasChanges {
                try context.save()
            }
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "BackgroundManager.fetchNextEpisodeUpNext.failed")
        }
    }
}
