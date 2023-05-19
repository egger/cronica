//
//  SettingsScreens.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/04/23.
//

import Foundation

enum SettingsScreens: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case about, appearance, behavior, developer, roadmap, notifications, sync, tipJar, settings
}
