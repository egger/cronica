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
    init() {
        self.gesture = (UserDefaults.standard.object(forKey: "gesture") == nil ? .favorite : DoubleTapGesture(rawValue: UserDefaults.standard.object(forKey: "gesture") as! Int)) ?? .favorite
    }
}
