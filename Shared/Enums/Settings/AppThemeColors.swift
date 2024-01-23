//
//  AppThemeColors.swift
//  Cronica
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
    case cherry = 17
    case skyBlue = 18
    case goldenrod = 19
    case coral = 20
    case turquoiseBlue = 21
    var localizableName: String {
        switch self {
        case .blue:  NSLocalizedString("Blue", comment: "App Theme Color")
        case .red:  NSLocalizedString("Red", comment: "App Theme Color")
        case .green:  NSLocalizedString("Green", comment: "App Theme Color")
        case .brown:  NSLocalizedString("Brown", comment: "App Theme Color")
        case .cyan:  NSLocalizedString("Cyan", comment: "App Theme Color")
        case .gray:  NSLocalizedString("Gray", comment: "App Theme Color")
        case .indigo:  NSLocalizedString("Indigo", comment: "App Theme Color")
        case .mint:  NSLocalizedString("Mint", comment: "App Theme Color")
        case .orange:  NSLocalizedString("Orange", comment: "App Theme Color")
        case .pink:  NSLocalizedString("Pink", comment: "App Theme Color")
        case .purple:  NSLocalizedString("Purple", comment: "App Theme Color")
        case .teal:  NSLocalizedString("Teal", comment: "App Theme Color")
        case .yellow:  NSLocalizedString("Yellow", comment: "App Theme Color")
        case .steel:  NSLocalizedString("Steel", comment: "App Theme Color")
        case .roseGold:  NSLocalizedString("Rose Gold", comment: "App Theme Color")
        case .turquoise:  NSLocalizedString("Turquoise", comment: "App Theme Color")
        case .lavender:  NSLocalizedString("Lavender", comment: "App Theme Color")
        case .cherry:  NSLocalizedString("Cherry", comment: "App Theme Color")
        case .skyBlue: NSLocalizedString("Sky Blue", comment: "App Theme Color")
        case .goldenrod: NSLocalizedString("Goldenrod", comment: "App Theme Color")
        case .coral: NSLocalizedString("Coral", comment: "App Theme Color")
        case .turquoiseBlue: NSLocalizedString("Turquoise Blue", comment: "App Theme Color")
        }
    }
    var color: Color {
        switch self {
        case .blue: .blue
        case .red: .red
        case .green: .green
        case .brown: .brown
        case .cyan: .cyan
        case .gray: .gray
        case .indigo: .indigo
        case .mint: .mint
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
        case .teal: .teal
        case .yellow: .yellow
        case .steel: Color(red: 0.57, green: 0.64, blue: 0.69)
        case .roseGold: Color(red: 0.91, green: 0.71, blue: 0.71)
        case .turquoise: Color(red: 0.0, green: 0.78, blue: 0.67)
        case .lavender: Color(red: 0.69, green: 0.49, blue: 0.86)
        case .cherry: Color(red: 0.8, green: 0.12, blue: 0.24)
        case .skyBlue: Color(red: 0.53, green: 0.81, blue: 0.98)
        case .goldenrod: Color(red: 0.85, green: 0.65, blue: 0.13)
        case .coral: Color(red: 1.0, green: 0.5, blue: 0.31)
        case .turquoiseBlue: Color(red: 0.0, green: 0.73, blue: 0.83)
        }
    }
}
