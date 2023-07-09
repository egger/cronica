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
        case .premiere: return NSLocalizedString("Premiere", comment: "")
        case .theatricalLimited: return NSLocalizedString("Theatrical Limited", comment: "")
        case .theatrical: return NSLocalizedString("Theatrical", comment: "")
        case .digital: return NSLocalizedString("Digital", comment: "")
        case .physical: return NSLocalizedString("Physical", comment: "")
        case .tv: return NSLocalizedString("TV", comment: "")
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
