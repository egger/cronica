//
//  SettingsScreen.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//

import Foundation

enum SettingsScreen: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case behavior, appearance, sync, tipJar, acknowledgements, sendFeedback
    case developer
}
