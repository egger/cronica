//
//  AppThemeModifier.swift
//  Story
//
//  Created by Alexandre Madeira on 03/01/23.
//

import SwiftUI

struct AppThemeModifier: ViewModifier {
    static let defaultsKey = "user_theme"
    @AppStorage(Self.defaultsKey) private var currentTheme: AppTheme = .system
    @Environment(\.colorScheme) var systemTheme
    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, currentTheme.overrideTheme ?? systemTheme)
    }
}
