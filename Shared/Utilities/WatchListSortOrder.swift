//
//  WatchListSortOrder.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/07/22.
//
import Foundation

enum WatchListSortOrder: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case optimized, type, status, favorites, people
    
    var title: String {
        switch self {
        case .optimized: return NSLocalizedString("Default", comment: "")
        case .type: return NSLocalizedString("Media Type", comment: "")
        case .status: return NSLocalizedString("Status", comment: "")
        case .favorites: return NSLocalizedString("Favorites", comment: "")
        case .people: return NSLocalizedString("People", comment: "")
        }
    }
}
