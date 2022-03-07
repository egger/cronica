//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//

import Foundation

struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}

struct Season: Decodable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int?
    let name, overview, posterPath: String
    var posterImage: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: posterPath)
    }
    let seasonNumber: Int
}

struct LastEpisodeToAir {
    let airDate: String?
    let episodeNumber, id: Int?
    let name, overview: String?
    let seasonNumber: Int?
    let stillPath: String?
}

struct ProductionCompany: Decodable {
    let id: Int
    let logoPath: String?
    let name, originCountry: String
}

struct ProductionCountry: Decodable {
    let name: String?
}

enum StyleType: Decodable {
    case poster
    case card
}

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
    var watchlistInt: Int {
        switch self {
        case .movie:
            return 0
        case .tvShow:
            return 1
        case .person:
            return 2
        }
    }
}
