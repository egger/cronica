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
    @Published var openYouTubeIn: YouTubeLinksBehavior {
        didSet {
            UserDefaults.standard.set(openYouTubeIn.rawValue, forKey: "openYouTubeIn")
        }
    }
    init() {
        self.gesture = (UserDefaults.standard.object(forKey: "gesture") == nil ? .favorite : DoubleTapGesture(rawValue: UserDefaults.standard.object(forKey: "gesture") as! Int)) ?? .favorite
        self.openYouTubeIn = (UserDefaults.standard.object(forKey: "openYouTubeIn") == nil ? .inCronica : YouTubeLinksBehavior(rawValue: UserDefaults.standard.object(forKey: "openYouTubeIn") as! Int)) ?? .inCronica
    }
}
