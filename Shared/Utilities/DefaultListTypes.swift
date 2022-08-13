//
//  DefaultListTypes.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//
import Foundation
import SwiftUI
import CoreData


enum DefaultListTypes: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case released, upcoming, production, favorites, watched, unwatched
    var title: String {
        switch self {
        case .released:
            return NSLocalizedString("Released", comment: "")
        case .upcoming:
            return NSLocalizedString("Upcoming", comment: "")
        case .production:
            return NSLocalizedString("In Production", comment: "")
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")
        case .watched:
            return NSLocalizedString("Watched", comment: "")
        case .unwatched:
            return NSLocalizedString("To Watch", comment: "")
        }
    }
}

class WatchlistItemFilter: ObservableObject {
    func filter(items: FetchedResults<WatchlistItem>, by filter: DefaultListTypes) -> [WatchlistItem] {
        var results: [WatchlistItem]
        switch filter {
        case .released:
            results = items.filter { $0.isReleasedMovie || $0.isReleasedTvShow }
        case .upcoming:
            results = items.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow }
        case .production:
            results = items.filter { $0.isInProduction }
        case .favorites:
            results = items.filter { $0.favorite }
        case .watched:
            results = items.filter { $0.watched }
        case .unwatched:
            results = items.filter { !$0.watched }
        }
        return results
    }
}
