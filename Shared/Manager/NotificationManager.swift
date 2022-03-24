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
    
    func scheduleNotification(content: Content) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.itemTitle
        notificationContent.body = "\(content.itemTitle) is out now!"
        notificationContent.sound = UNNotificationSound.default
        
        let dateComponent = Calendar.current.dateComponents([], from: content.release)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: content.itemTitle,
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        print("Notification request added for \(content.itemTitle).")
    }
    
    func removeNotification(content: Content) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [content.itemTitle])
        print("Notification request removed for \(content.itemTitle).")
    }
}
