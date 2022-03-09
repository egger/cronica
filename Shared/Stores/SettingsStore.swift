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
        static let contentRegion = "content_region"
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
            Keys.contentRegion: ContentRegion.enUS.rawValue
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
    enum ContentRegion: String, CaseIterable {
        case enUS = "en-US"
        case ptBR = "pt-BR"
        var title: String {
            switch self {
            case .enUS:
                return "English (United States)"
            case .ptBR:
                return "Portuguese (Brazil)"
            }
        }
    }
    var contentRegion: ContentRegion {
            get {
                return defaults.string(forKey: Keys.contentRegion)
                    .flatMap { ContentRegion(rawValue: $0) } ?? .enUS
            }
            set {
                defaults.set(newValue.rawValue, forKey: Keys.contentRegion)
            }
        }
}
