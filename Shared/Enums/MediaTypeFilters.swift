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
            return NSLocalizedString("mediaTypeFiltersNoFilter", comment: "")
        case .movies:
            return NSLocalizedString("mediaTypeFiltersMovies", comment: "")
        case .tvShows:
            return NSLocalizedString("mediaTypeFiltersTvShows", comment: "")
        }
    }
}

enum WatchlistSortOrder: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case titleAsc, titleDesc, dateAsc, dateDesc, ratingAsc, ratingDesc
    
    var localizableName: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
