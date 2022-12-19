//
//  WatchlistSubtitleRow.swift
//  Story
//
//  Created by Alexandre Madeira on 18/12/22.
//

import Foundation

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
