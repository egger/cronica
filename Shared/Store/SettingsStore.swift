//
//  SettingsStore.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import Foundation

class SettingsStore: ObservableObject {
    @Published var gesture: DoubleTapGesture {
        didSet {
            UserDefaults.standard.set(gesture.rawValue, forKey: "gesture")
        }
    }
    @Published var useLegacy: UseLegacyWatchlist {
        didSet {
            UserDefaults.standard.set(useLegacy.rawValue, forKey: "useLegacy")
        }
    }
    init() {
        self.gesture = (UserDefaults.standard.object(forKey: "gesture") == nil ? .favorite : DoubleTapGesture(rawValue: UserDefaults.standard.object(forKey: "gesture") as? Int ?? DoubleTapGesture.favorite.rawValue)) ?? .favorite
        self.useLegacy = (UserDefaults.standard.object(forKey: "useLegacy") == nil ? .legacy : UseLegacyWatchlist(rawValue: UserDefaults.standard.object(forKey: "useLegacy") as? Int ?? UseLegacyWatchlist.legacy.rawValue)) ?? .legacy
    }
}
