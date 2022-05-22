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
    
    func schedule(content: Content) {
        let identifier: String = "\(content.itemTitle)+\(content.id)"
        let title = content.itemTitle
        var body: String
        if content.itemContentMedia == .movie {
            body = NSLocalizedString("The movie will be released today.", comment: "")
        } else {
            body = NSLocalizedString("New episode available.", comment: "")
        }
        var date: Date?
        if content.itemContentMedia == .movie {
            date = content.itemTheatricalDate!
        } else if content.itemContentMedia == .tvShow {
            date = content.nextEpisodeDate!
        } else {
            date = content.itemFallbackDate
        }
        self.requestAuthorization { granted in
            if !granted {
                return
            }
        }
        if let date = date {
            self.scheduleNotification(identifier: identifier,
                                      title: title,
                                      body: body,
                                      date: date)
        }
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, date: Date) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        let dateComponent: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                            from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                TelemetryManager.send("scheduleNotificationError",
                                      with: ["Error:":"\(error.localizedDescription)"])
            }
            TelemetryManager.send("scheduleNotification")
        }
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        TelemetryManager.send("removeNotification")
    }
    
    func isNotificationScheduled(identifier: String) -> Bool {
        var value: Bool = false
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                if notification.identifier == identifier {
                    value = true
                }
            }
        }
        return value
    }
}
