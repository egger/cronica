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

struct SeriesSection: Decodable, Identifiable {
    var id = UUID()
    let result: [Series]
    let endpoint: SeriesEndpoint.RawValue
    var title: String {
        ""
    }
    var style: String {
        ""
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
    let name: String
    let networks: [Network]?
    let numberOfEpisodes, numberOfSeasons: Int
    let originCountry: [String]?
    let originalLanguage, originalName, overview: String?
    let popularity, voteAverage: Double?
    private let posterPath, backdropPath: String
    let productionCompanies: [Network]?
    let seasons: [Season]?
    let status, tagline, type: String?
    let voteCount: Int?
    let credits: Credits?
    var posterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
    }
    var backdropImage: URL {
        return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath)")!
    }
    let inWatchlist: Bool?
}
