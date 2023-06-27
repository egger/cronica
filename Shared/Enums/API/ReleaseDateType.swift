//
//  ReleaseDateType.swift
//  Story
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
        case .premiere: return "Premiere"
        case .theatricalLimited: return "Theatrical Limited"
        case .theatrical: return "Theatrical"
        case .digital: return "Digital"
        case .physical: return "Physical"
        case .tv: return "TV"
        }
    }
    
    var toInt: Int {
        switch self {
        case .premiere: return 1
        case .theatricalLimited: return 2
        case .theatrical: return 3
        case .digital: return 4
        case .physical: return 5
        case .tv: return 6
        }
    }
}
