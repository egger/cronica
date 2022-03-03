//
//  Content.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation

struct ContentResponse: Identifiable, Decodable {
    let id: String?
    let results: [Content]
}

struct ContentSection: Identifiable {
    var id = UUID()
    let results: [Content]
    let endpoint: ContentEndpoints
    var title: String {
        endpoint.title
    }
    var style: StyleType {
        switch endpoint {
        case .upcoming:
            return StyleType.poster
        case .popular:
            return StyleType.card
        case .latest:
            return StyleType.poster
        case .nowPlaying:
            return StyleType.poster
        }
    }
}

struct Content: Identifiable, Decodable {
    let id: Int
    private let title, name, overview: String?
    private let posterPath, backdropPath: String?
    private let releaseDate, status: String?
    private let runtime, numberOfEpisodes, numberOfSeasons: Int?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let genres: [Genre]?
    let credits: Credits?
    let similar: ContentResponse?
}

extension Content {
    var itemTitle: String {
        title ?? name!
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("No details available.",
                                      comment: "No overview provided by the service.")
    }
    var posterImage500: URL? {
        if posterPath != nil {
            return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath!)")!
        } else {
            return nil
        }
    }
    var cardImage: URL? {
        if backdropPath != nil {
            return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath!)")!
        } else {
            return nil
        }
    }
    var itemGenre: String {
        if genres != nil {
            return genres!.first!.name!
        } else {
            return ""
        }
    }
    var itemCountry: String {
        if productionCountries != nil {
            return productionCountries!.first!.name!
        } else {
            return ""
        }
    }
    var itemInfo: String? {
        if !itemGenre.isEmpty && !releaseDateString.isEmpty {
            return "\(itemGenre), \(releaseDateString)"
        } else {
            return nil
        }
    }
    var itemStatus: String {
        status ?? NSLocalizedString("No information available",
                                    comment: "API didn't provided status information.")
    }
    var itemRuntime: String {
        return Util.durationFormatter.string(from: TimeInterval(runtime!) * 60) ?? "n/a"
    }
    var releaseDateString: String {
        guard let releaseDate = self.releaseDate,
              let date = Util.dateFormatter.date(from: releaseDate) else {
            return ""
        }
        return Util.dateString.string(from: date)
    }
    var release: Date {
        return Util.dateFormatter.date(from: releaseDateString) ?? Date()
    }
}

struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}

struct Season: Decodable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int?
    let name, overview, posterPath: String
    var posterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
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
    let iso3166_1, name: String?
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
            return "Movie"
        case .tvShow:
            return "TV Show"
        case .person:
            return "People"
        }
    }
}
