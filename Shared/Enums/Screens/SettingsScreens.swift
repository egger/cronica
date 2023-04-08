//
//  SettingsScreens.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/04/23.
//

import Foundation

enum SettingsScreens: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case acknowledgements, appearance, behavior, developer, roadmap, feedback, notifications, privacy, sync, tipJar, settings
}
