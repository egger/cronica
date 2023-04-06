//
//  MediaTypeFilters.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/04/23.
//

import Foundation

enum MediaTypeFilters: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case noFilter, movies, tvShows
    var localizableTitle: String {
        switch self {
        case .noFilter:
            return NSLocalizedString("mediaTypeFiltersNoFilter", comment: "")
        case .movies:
            return NSLocalizedString("mediaTypeFiltersMovies", comment: "")
        case .tvShows:
            return NSLocalizedString("mediaTypeFiltersTvShows", comment: "")
        }
    }
}
