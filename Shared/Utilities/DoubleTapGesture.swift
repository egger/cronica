//
//  DoubleTapGesture.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import Foundation

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
