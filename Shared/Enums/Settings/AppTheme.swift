//
//  AppTheme.swift
//  Cronica
//
//  Created by Alexandre Madeira on 03/01/23.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case system, light, dark
    var overrideTheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    var localizableName: String {
        switch self {
        case .system:
            return NSLocalizedString("System", comment: "")
        case .light:
            return NSLocalizedString("Light", comment: "")
        case .dark:
            return NSLocalizedString("Dark", comment: "")
        }
    }
}
