//
//  Screens.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation
#if !os(watchOS)
enum Screens: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case home, explore, watchlist
#if os(iOS)
    case search, settings
#endif
    
    var title: String {
        switch self {
        case .home: return NSLocalizedString("Home", comment: "")
        case .explore: return NSLocalizedString("Explore", comment: "")
        case .watchlist: return NSLocalizedString("Watchlist", comment: "")
#if os(iOS)
        case .search: return NSLocalizedString("Search", comment: "")
        case .settings: return NSLocalizedString("Settings", comment: "")
#endif
        }
    }
}
#else
enum Screens: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case trending, watchlist, upNext, upcoming, search, settings
    
    var title: String {
        switch self {
        case .trending: return NSLocalizedString("Trending", comment: "")
        case .watchlist: return NSLocalizedString("Watchlist", comment: "")
        case .upcoming: return NSLocalizedString("Upcoming", comment: "")
        case .upNext: return NSLocalizedString("upNext", comment: "")
        case .search: return NSLocalizedString("Search", comment: "")
        case .settings: return NSLocalizedString("Settings", comment: "")
        }
    }
}
#endif
