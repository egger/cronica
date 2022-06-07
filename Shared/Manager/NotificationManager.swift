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
        let identifier: String = "\(notificationContent.itemTitle)+\(notificationContent.id)"
        let title = notificationContent.itemTitle
        var body: String
        if notificationContent.itemContentMedia == .movie {
            body = NSLocalizedString("The movie will be released today.", comment: "")
        } else {
            body = NSLocalizedString("New episode available.", comment: "")
        }
        var date: Date?
        if notificationContent.itemContentMedia == .movie {
            date = notificationContent.itemTheatricalDate!
        } else if notificationContent.itemContentMedia == .tvShow {
            date = notificationContent.nextEpisodeDate!
        } else {
            date = notificationContent.itemFallbackDate
        }
        self.requestAuthorization { granted in
            if !granted {
                return
            }
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
                print(error.localizedDescription)
            }
        }
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
