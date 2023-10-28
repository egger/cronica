//
//  SmartFiltersTypes.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//
import Foundation

/// The type of lists supported by WatchlistView.
///
/// This value is used to provide filter functionality for WatchlistView.
enum SmartFiltersTypes: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case released, production, watching, notWatched, watched, favorites, pin, archive
    var title: String {
        switch self {
        case .released:
            return NSLocalizedString("Released", comment: "")
        case .production:
            return NSLocalizedString("In Production", comment: "")
        case .watched:
            return NSLocalizedString("Watched", comment: "")
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")
        case .pin:
            return NSLocalizedString("Pins", comment: "")
        case .archive:
            return NSLocalizedString("Archive", comment: "")
        case .watching:
            return NSLocalizedString("Watching", comment: "")
        case .notWatched:
            return NSLocalizedString("Not Watched", comment: "")
        }
    }
}
