//
//  MediaTypeFilters.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 06/04/23.
//

import Foundation

enum MediaTypeFilters: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case showAll, movies, tvShows
    var localizableTitle: String {
        switch self {
        case .showAll:
            return NSLocalizedString("All", comment: "")
        case .movies:
            return NSLocalizedString("Movies", comment: "")
        case .tvShows:
            return NSLocalizedString("TV Shows", comment: "")
        }
    }
}

enum WatchlistSortOrder: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case titleAsc, titleDesc, dateAsc, dateDesc, ratingAsc, ratingDesc
    
    var localizableName: String {
        switch self {
        case .titleAsc:
            return NSLocalizedString("Title (Asc)", comment: "")
        case .titleDesc:
            return NSLocalizedString("Title (Desc)", comment: "")
        case .dateAsc:
            return NSLocalizedString("Date (Asc)", comment: "")
        case .dateDesc:
            return NSLocalizedString("Date (Desc)", comment: "")
        case .ratingAsc:
            return NSLocalizedString("Rating (Asc)", comment: "")
        case .ratingDesc:
            return NSLocalizedString("Rating (Desc)", comment: "")
        }
    }

}
