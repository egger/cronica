//
//  WatchlistItemType.swift
//  Story
//
//  Created by Alexandre Madeira on 18/12/22.
//

import Foundation

enum WatchlistItemType: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case list = 0
    case poster = 1
    case card = 2
    var localizableName: String {
        switch self {
        case .list: return NSLocalizedString("watchlistItemTypeList", comment: "")
        case .poster: return NSLocalizedString("watchlistItemTypePoster", comment: "")
        case .card: return NSLocalizedString("watchlistItemTypeCard", comment: "")
        }
    }
}
