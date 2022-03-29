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
        static let userLoggedIn = "user_logged"
    }
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.userLoggedIn: false
        ])
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    var isUserLogged: Bool {
        set { defaults.set(newValue, forKey: Keys.userLoggedIn) }
        get { defaults.bool(forKey: Keys.userLoggedIn) }
    }
}
