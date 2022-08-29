//
//  LocalNotificationManager.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import Foundation
import UserNotifications
import SwiftUI
import TelemetryClient

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var settings: UNNotificationSettings?
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            self.fetchNotificationSettings()
            completion(granted)
        }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func schedule(notificationContent: ItemContent) {
        self.requestAuthorization { granted in
            if !granted {
                return
            }
        }
        let identifier: String = notificationContent.itemNotificationID
        let title = notificationContent.itemTitle
        var body: String
        if notificationContent.itemContentMedia == .movie {
            body = NSLocalizedString("The movie will be released today.", comment: "")
        } else {
            body = NSLocalizedString("New episode available.", comment: "")
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
#if targetEnvironment(simulator)
                print(error.localizedDescription)
#else
                TelemetryManager.send("scheduleNotification", with: ["error":"\(error.localizedDescription)"])
#endif
            }
        }
#if DEBUG
        print(request as Any)
#endif
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func fetchUpcomingNotifications() async -> [ItemContent]? {
        var identifiers = [String]()
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        for item in notifications {
            identifiers.append(item.identifier)
#if targetEnvironment(simulator)
            print(item.identifier)
#endif
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
#if targetEnvironment(simulator)
        for item in items {
            print("\(item.itemTitle) with notification id of: \(item.itemNotificationID)")
        }
#endif
        return items
    }
}
