//
//  AppThemeColors.swift
//  Story
//
//  Created by Alexandre Madeira on 18/12/22.
//

import SwiftUI

enum AppThemeColors: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case blue = 0
    case red = 1
    case green = 2
    case brown = 3
    case cyan = 4
    case gray = 5
    case indigo = 6
    case mint = 7
    case orange = 8
    case pink = 9
    case purple = 10
    case teal = 11
    case yellow = 12
    case steel = 13
    case roseGold = 14
    case turquoise = 15
    case lavender = 16
    var localizableName: String {
        switch self {
        case .blue: return NSLocalizedString("appThemeColorsBlue", comment: "")
        case .red: return NSLocalizedString("appThemeColorsRed", comment: "")
        case .green: return NSLocalizedString("appThemeColorsGreen", comment: "")
        case .brown: return NSLocalizedString("appThemeColorsBrown", comment: "")
        case .cyan: return NSLocalizedString("appThemeColorsCyan", comment: "")
        case .gray: return NSLocalizedString("appThemeColorsGray", comment: "")
        case .indigo: return NSLocalizedString("appThemeColorsIndigo", comment: "")
        case .mint: return NSLocalizedString("appThemeColorsMint", comment: "")
        case .orange: return NSLocalizedString("appThemeColorsOrange", comment: "")
        case .pink: return NSLocalizedString("appThemeColorsPink", comment: "")
        case .purple: return NSLocalizedString("appThemeColorsPurple", comment: "")
        case .teal: return NSLocalizedString("appThemeColorsTeal", comment: "")
        case .yellow: return NSLocalizedString("appThemeColorsYellow", comment: "")
        case .steel: return NSLocalizedString("appThemeColorSteel", comment: "")
        case .roseGold: return NSLocalizedString("appThemeColorRoseGold", comment: "")
        case .turquoise: return NSLocalizedString("appThemeColorTurquoise", comment: "")
        case .lavender: return NSLocalizedString("appThemeColorLavender", comment: "")
        }
    }
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .brown: return .brown
        case .cyan: return .cyan
        case .gray: return .gray
        case .indigo: return .indigo
        case .mint: return .mint
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .teal: return .teal
        case .yellow: return .yellow
        case .steel: return Color(red: 0.57, green: 0.64, blue: 0.69)
        case .roseGold: return Color(red: 0.91, green: 0.71, blue: 0.71)
        case .turquoise: return Color(red: 0.0, green: 0.78, blue: 0.67)
        case .lavender: return Color(red: 0.69, green: 0.49, blue: 0.86)
        }
    }
}
