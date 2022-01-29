//
//  Series.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import Foundation

struct SeriesResponse: Decodable, Identifiable {
    var id: String?
    let results: [Series]
}

struct SeriesSection: Identifiable {
    var id = UUID()
    let result: [Series]
    let endpoint: SeriesEndpoint
    var title: String {
        endpoint.title
    }
    var style: String {
        switch endpoint {
        case .latest:
            return "card"
        case .airingToday:
            return "poster"
        case .onTheAir:
            return "poster"
        }
    }
}

struct Series: Decodable, Identifiable, Hashable {
    static func == (lhs: Series, rhs: Series) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: Int
    let adult: Bool?
    let episodeRunTime: [Int]
    let firstAirDate: String
    let genres: [Genre]?
    let homepage: String
    let inProduction: Bool?
    let languages: [String]?
    let lastAirDate: String?
    let lastEpisodeToAir, nextEpisodeToAir: TEpisodeToAir?
    private let name: String
    let networks: [Network]?
    let numberOfEpisodes, numberOfSeasons: Int
    let originCountry: [String]?
    let originalLanguage, originalName, overview: String?
    private let posterPath, backdropPath: String
    let productionCompanies: [Network]?
    let seasons: [Season]?
    let status, tagline, type: String?
    let credits: Credits?
    var posterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
    }
    var backdropImage: URL {
        return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath)")!
    }
    var title: String {
        return name
    }
    let inWatchlist: Bool?
}

struct Season: Decodable, Identifiable {
    let airDate: String?
    let episodeCount, id: Int
    let name, overview, posterPath: String
    let seasonNumber: Int
}

struct TEpisodeToAir: Decodable, Identifiable {
    let airDate: String?
    let id: Int
    let episodeNumber: Int?
    let name, overview, productionCode: String?
    let seasonNumber: Int?
    let stillPath: String?
    let voteAverage: Double?
    let voteCount: Int?
}
