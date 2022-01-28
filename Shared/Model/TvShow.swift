//
//  TvShow.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import Foundation

struct TvShow {
    let adult: Bool?
    let episodeRunTime: [Int]
    let firstAirDate: String
    let genres: [Genre]?
    let homepage: String
    let id: Int
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
}

struct Season {
    let airDate: String
    let episodeCount, id: Int
    let name, overview, posterPath: String
    let seasonNumber: Int
}

struct TEpisodeToAir {
    let airDate: String?
    let episodeNumber, id: Int?
    let name, overview, productionCode: String?
    let seasonNumber: Int?
    let stillPath: String?
    let voteAverage: Double?
    let voteCount: Int?
}


struct Network {
    let name: String
    let id: Int
    let logoPath: String?
    let originCountry: String
}
