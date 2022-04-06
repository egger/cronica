//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import UserNotifications
import SwiftUI

@MainActor class DetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    var content: Content? { phase.value ?? nil }
    let context: WatchlistController = WatchlistController.shared
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if phase.value == nil {
            phase = .empty
            do {
                let content = try await self.service.fetchContent(id: id, type: type)
                phase = .success(content)
            } catch {
                phase = .failure(error)
            }
        }
    }
    
    func update() {
        if let content = content {
            if context.isItemInList(id: content.id) {
                let item = try? context.getItem(id: WatchlistItem.ID(content.id))
                if let item = item {
                    let identifier: String = "\(content.itemTitle)+\(content.id)"
                    if context.isNotificationScheduled(id: content.id) {
                        notification.removeNotification(identifier: identifier)
                    }
                    try? context.removeItem(id: item)
                }
            } else {
                let notify = itemCanNotify()
                context.saveItem(content: content, notify: notify)
                if notify { try? notificationManager() }
            }
        }
    }
    
    func itemCanNotify() -> Bool {
        if let item = content {
            if let date = item.itemTheatricalDate {
                if date > Date() {
                    return true
                }
            }
            if let date = item.nextEpisodeDate {
                if date > Date() {
                    return true
                }
            }
        }
        return false
    }
    
    private func notificationManager() throws {
        if let content = content {
            let identifier: String = "\(content.itemTitle)+\(content.id)"
            var body: String
            if content.itemContentMedia == .movie {
                body = "The movie '\(content.itemTitle)' is out now!"
            } else {
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
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    self.notification.scheduleNotification(identifier: identifier,
                                                                title: content.itemTitle,
                                                                body: body,
                                                                date: date)
                } else if settings.authorizationStatus == .notDetermined {
                    self.notification.requestAuthorization { granted in
                        if granted == true {
                            self.notification.scheduleNotification(identifier: identifier,
                                                                        title: content.itemTitle,
                                                                        body: body,
                                                                        date: date)
                        }
                    }
                }
            }
        }
    }
}
