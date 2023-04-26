//
//  Screens.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum Screens: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case home, explore, watchlist
#if os(iOS)
    case search
#endif
    
    var title: String {
        switch self {
        case .home:
            return NSLocalizedString("Home", comment: "")
        case .explore:
            return NSLocalizedString("Explore", comment: "")
        case .watchlist:
            return NSLocalizedString("Watchlist", comment: "")
        case .search:
            return NSLocalizedString("Search", comment: "")
        }
    }
}
