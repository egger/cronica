//
//  MediaType.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum MediaType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case movie, person
    case tvShow = "tv"
    var title: String {
        switch self {
        case .movie:
            return NSLocalizedString("Movie", comment: "")
        case .tvShow:
            return NSLocalizedString("TV Show", comment: "")
        case .person:
            return NSLocalizedString("People", comment: "")
        }
    }
    var toInt: Int64 {
        switch self {
        case .movie: return 0
        case .tvShow: return 1
        case .person: return 2
        }
    }
    var append: String {
        switch self {
        case .movie:
            return "credits,recommendations,release_dates,videos"
        case .person:
            return "combined_credits,images"
        case .tvShow:
            return "credits,recommendations,videos"
        }
    }
}


