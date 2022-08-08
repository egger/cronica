//
//  ListItemsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/08/22.
//

import SwiftUI
import CoreData
import Foundation


@MainActor
class TableListViewModel: ObservableObject {
    @Published var items = [WatchlistItem]()
    private let context = PersistenceController.shared
    
    func fetch(filter: DefaultListsOrder) {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let list = try? self.context.container.viewContext.fetch(request)
        if let list {
            switch filter {
            case .releasedMovies:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .releasedShows:
                items.append(contentsOf: list.filter { $0.isReleasedTvShow })
            case .upcomingMovies:
                items.append(contentsOf: list.filter { $0.isUpcomingMovie })
            case .upcomingShows:
                items.append(contentsOf: list.filter { $0.isUpcomingTvShow })
            case .inProduction:
                items.append(contentsOf: list.filter { $0.isInProduction })
            case .movies:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .shows:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .toWatch:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .watched:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .favorites:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            case .people:
                items.append(contentsOf: list.filter { $0.isReleasedMovie })
            }
        }
    }
}



enum DefaultListItems: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case movies, shows, upcoming, production, favorites, watched, unwatched
    
    var title: String {
        switch self {
        case .movies:
            return "Movies"
        case .shows:
            return "Shows"
        case .upcoming:
            return "Upcoming"
        case .production:
            return "In Production"
        case .favorites:
            return "Favorites"
        case .watched:
            return "Watched"
        case .unwatched:
            return "Unwatched"
        }
    }
}


enum DefaultListsOrder: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case releasedMovies, releasedShows, upcomingMovies, upcomingShows, inProduction
    case movies, shows, toWatch, watched, favorites, people
    
    var title: String {
        switch self {
        case .releasedMovies:
            return NSLocalizedString("Released Movies", comment: "")
        case .releasedShows:
            return NSLocalizedString("Released Shows", comment: "")
        case .upcomingMovies:
            return NSLocalizedString("Upcoming Movies", comment: "")
        case .upcomingShows:
            return NSLocalizedString("Upcoming Shows", comment: "")
        case .inProduction:
            return NSLocalizedString("In Production", comment: "")
        case .movies:
            return NSLocalizedString("Movies", comment: "")
        case .shows:
            return NSLocalizedString("TV Shows", comment: "")
        case .toWatch:
            return NSLocalizedString("To Watch", comment: "")
        case .watched:
            return NSLocalizedString("Watched", comment: "")
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")
        case .people:
            return NSLocalizedString("People", comment: "")
        }
    }
}
