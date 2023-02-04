//
//  LocalNotificationManager.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var settings: UNNotificationSettings?
    @AppStorage("isNotificationAllowed") var notificationAllowed = true
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .provisional]) { granted, error in
            self.fetchNotificationSettings()
            completion(granted)
            if let error {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "NotificationManager.requestAuthorization")
            }
        }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func schedule(_ notificationContent: ItemContent) {
        self.requestAuthorization { granted in
            if !granted {
                self.notificationAllowed = false
                return
            } else {
                self.notificationAllowed = true
            }
        }
        let identifier = notificationContent.itemNotificationID
        let title = notificationContent.itemTitle
        var body: String
        if notificationContent.itemContentMedia == .movie {
            body = NSLocalizedString("The movie will be released today.", comment: "")
        } else {
            body = NSLocalizedString("Next episode arrives today.", comment: "")
        }
        var date: Date?
        if notificationContent.itemContentMedia == .movie {
            date = notificationContent.itemTheatricalDate
        } else if notificationContent.itemContentMedia == .tvShow {
            date = notificationContent.nextEpisodeDate
        } else {
            date = notificationContent.itemFallbackDate
        }
        if let date {
            self.scheduleNotification(identifier: identifier,
                                      title: title,
                                      message: body,
                                      date: date)
        }
    }
    
    private func scheduleNotification(identifier: String, title: String, message: String, date: Date) {
#if os(tvOS)
#else
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = message
        notificationContent.sound = UNNotificationSound.default
        let dateComponent: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                            from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "scheduleNotification")
            }
        }
#endif
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeNotificationSchedule(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let type = identifier.last ?? "0"
        var media: MediaType = .movie
        if type == "1" {
            media = .tvShow
        }
        let id = identifier.dropLast(2)
        let item = try? PersistenceController.shared.fetch(for: Int64(id)!, media: media)
        guard let item else { return }
        item.notify = false
    }
    
    func removeDeliveredNotification(identifier: String) {
#if os(tvOS)
#else
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
#endif
    }
    
    func removeAllDeliveredNotifications() {
#if os(tvOS)
#else
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
#endif
    }
    
    private func getUpcomingNotificationsId() async -> [String] {
        var identifiers = [String]()
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        for item in notifications {
            identifiers.append(item.identifier)
        }
        return identifiers
    }
    
    private func getDeliveredNotificationsId() async -> [String] {
#if os(tvOS)
        return []
#else
        var identifiers = [String]()
        let notifications = await UNUserNotificationCenter.current().deliveredNotifications()
        if notifications.isEmpty {
            return identifiers
        } else {
            for item in notifications {
                if item.request.identifier.contains("@") {
                    identifiers.append(item.request.identifier)
                }
            }
        }
        return identifiers
#endif
    }
    
    func fetchDeliveredNotifications() async -> [ItemContent] {
        var items = [ItemContent]()
        let notifications = await getDeliveredNotificationsId()
        if notifications.isEmpty { return items }
        for notification in notifications {
            let type = notification.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = notification.dropLast(2)
            let item = try? await NetworkService.shared.fetchItem(id: Int(id)!, type: media)
            if let item {
                items.append(item)
            }
        }
        return items
    }
    
    func fetchUpcomingNotifications() async throws -> [WatchlistItem] {
        var items = [WatchlistItem]()
        let notifications = await getUpcomingNotificationsId()
        for notification in notifications {
            let type = notification.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = notification.dropLast(2)
            do {
                let item = try PersistenceController.shared.fetch(for: Int64(id)!, media: media)
                if let item {
                    items.append(item)
                }
            } catch {
                throw error
            }
        }
        return items
    }
    
    func fetchUpcomingNotifications() async -> [ItemContent]? {
        var identifiers = [String]()
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        for item in notifications {
            identifiers.append(item.identifier)
        }
        var items = [ItemContent]()
        if identifiers.isEmpty {
            return items
        }
        let service = NetworkService.shared
        for identifier in identifiers {
            let type = identifier.last ?? "0"
            var media: MediaType = .movie
            if type == "1" {
                media = .tvShow
            }
            let id = identifier.dropLast(2)
            do {
                let item = try await service.fetchItem(id: Int(id)!, type: media)
                items.append(item)
            } catch {
                return nil
            }
        }
        return items
    }
}
