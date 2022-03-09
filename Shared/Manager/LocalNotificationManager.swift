//
//  LocalNotificationManager.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import Foundation
import SwiftUI

class LocalNotificationManager: ObservableObject {
    var notifications = [Notification]()
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else {
                print("Notifications not permitted")
            }
        }
    }
}
