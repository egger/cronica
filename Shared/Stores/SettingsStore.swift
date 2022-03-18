//
//  SettingsStore.swift
//  Story
//
//  Created by Alexandre Madeira on 07/03/22.
//

import Foundation
import Combine

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let notificationEnabled = "notifications_enabled"
        static let automaticallyNotifications = "automatically_notifications"
        static let userLoggedIn = "user_logged"
        static let welcomeScreenDisplayed = "welcome_screen_displayed"
    }
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.notificationEnabled: true,
            Keys.automaticallyNotifications: true,
            Keys.userLoggedIn: false,
            Keys.welcomeScreenDisplayed: false
        ])
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    var isNotificationEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.notificationEnabled) }
        get { defaults.bool(forKey: Keys.notificationEnabled) }
    }
    var isAutomaticallyNotification: Bool {
        set { defaults.set(newValue, forKey: Keys.automaticallyNotifications) }
        get { defaults.bool(forKey: Keys.automaticallyNotifications) }
    }
    var isUserLogged: Bool {
        set { defaults.set(newValue, forKey: Keys.userLoggedIn) }
        get { defaults.bool(forKey: Keys.userLoggedIn) }
    }
    var isWelcomeScreenDisplayed: Bool {
        set { defaults.set(newValue, forKey: Keys.welcomeScreenDisplayed) }
        get { defaults.bool(forKey: Keys.welcomeScreenDisplayed) }
    }
}
