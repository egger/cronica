//
//  ReleaseDateType.swift
//  Cronica
//
//  Created by Alexandre Madeira on 27/06/23.
//

import Foundation

/// The release types and statuses used on TMDB
///
///
/// https://developers.themoviedb.org/3/movies/get-movie-release-dates
enum ReleaseDateType: String, Identifiable, Codable {
    var id: String { rawValue }
    case premiere, theatricalLimited, theatrical, digital, physical, tv
    
    var localizedTitle: String {
        switch self {
        case .premiere: String(localized: "Premiere")
        case .theatricalLimited: String(localized: "Theatrical Limited")
        case .theatrical: String(localized: "Theatrical")
        case .digital: String(localized: "Digital")
        case .physical: String(localized: "Physical")
        case .tv: String(localized: "TV")
        }
    }
    
    var toInt: Int {
        switch self {
        case .premiere: 1
        case .theatricalLimited: 2
        case .theatrical: 3
        case .digital: 4
        case .physical: 5
        case .tv: 6
        }
    }
}
