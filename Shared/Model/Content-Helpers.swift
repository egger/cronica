//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

//MARK: Season
struct Season: Decodable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int?
    let episodes: [Episode]?
    private let name, overview, posterPath: String?
    let seasonNumber: Int
}
extension Season {
    var itemTitle: String {
        name ?? NSLocalizedString("Not Available", comment: "")
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("Not Available", comment: "")
    }
    var posterImage: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: posterPath) ?? nil
    }
}
//MARK: Episode
struct Episode: Identifiable, Decodable {
    let id: Int
    let airDate: String
    let episodeNumber: Int
    let crew, guestStars: [Person]?
    private let name, overview, stillPath: String?
    let seasonNumber: Int
}
extension Episode {
    var itemTitle: String {
        name ?? NSLocalizedString("N/A", comment: "")
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("N/A", comment: "")
    }
    var itemImageMedium: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: stillPath) ?? nil
    }
    var itemImageLarge: URL? {
        return Utilities.imageUrlBuilder(size: .large, path: stillPath) ?? nil
    }
}
//MARK: Production
struct ProductionCompany: Decodable {
    let id: Int
    let logoPath: String?
    let name: String
}
struct ProductionCountry: Decodable {
    let name: String?
}
//MARK: Genre
struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}
//MARK: Utilities
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
    var headline: String {
        switch self {
        case .movie:
            return "Movies"
        case .person:
            return "Person"
        case .tvShow:
            return "Shows"
        }
    }
}
