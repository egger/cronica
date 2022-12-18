//
//  DoubleTapGesture.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import SwiftUI

/// Double tap values for the CoverImage gesture.
enum DoubleTapGesture: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case favorite = 0
    case watched = 1
    var title: String {
        switch self {
        case .favorite:
            return NSLocalizedString("Favorite", comment: "")
        case .watched:
            return NSLocalizedString("Watched", comment: "")
        }
    }
}

enum WatchlistSubtitleRow: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case none = 0
    case genre = 1
    case date = 2
    var localizableName: String {
        switch self {
        case .none: return NSLocalizedString("watchlistSubtitleRowNone", comment: "")
        case .genre: return NSLocalizedString("watchlistSubtitleRowGenre", comment: "")
        case .date: return NSLocalizedString("watchlistSubtitleRowDate", comment: "")
        }
    }
}



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
    var localizableName: String {
        switch self {
        case .blue: return NSLocalizedString("appThemeColorsBlue", comment: "")
        case .red: return NSLocalizedString("appThemeColorsRed", comment: "")
        case .green: return NSLocalizedString("appThemeColorsGreen", comment: "")
        case .brown:
            return NSLocalizedString("appThemeColorsBrown", comment: "")
        case .cyan:
            return NSLocalizedString("appThemeColorsCyan", comment: "")
        case .gray:
            return NSLocalizedString("appThemeColorsGray", comment: "")
        case .indigo:
            return NSLocalizedString("appThemeColorsIndigo", comment: "")
        case .mint:
            return NSLocalizedString("appThemeColorsMint", comment: "")
        case .orange:
            return NSLocalizedString("appThemeColorsOrange", comment: "")
        case .pink:
            return NSLocalizedString("appThemeColorsPink", comment: "")
        case .purple:
            return NSLocalizedString("appThemeColorsPurple", comment: "")
        case .teal:
            return NSLocalizedString("appThemeColorsTeal", comment: "")
        case .yellow:
            return NSLocalizedString("appThemeColorsYellow", comment: "")
        }
    }
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .brown:
            return .brown
        case .cyan:
            return .cyan
        case .gray:
            return .gray
        case .indigo:
            return .indigo
        case .mint:
            return .mint
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .teal:
            return .teal
        case .yellow:
            return .yellow
        }
    }
}
