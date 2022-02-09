//
//  TvShow.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import Foundation

struct TvResponse: Decodable, Identifiable {
    let id: String?
    let results: [TvShow]
}

struct TvSection: Identifiable {
    var id = UUID()
    let results: [TvShow]
    let endpoint: SeriesEndpoint
    var title: String {
        endpoint.title
    }
    var style: String {
        switch endpoint {
        case .latest:
            return "poster"
        case .popular:
            return "card"
        case .onTheAir:
            return "poster"
        case .airingToday:
            return "poster"
        }
    }
}

struct TvShow: Decodable, Identifiable {
    let id: Int
    let name: String
    let posterPath: String
    let backdropPath, overview, status: String?
    let numberOfEpisodes, numberOfSeasons: Int?
    let seasons: [Season]?
    var posterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
    }
    var backdropImage: URL {
        return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath ?? posterPath)")!
    }
    var title: String {
        return name
    }
}
        
struct Season: Decodable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int?
    let name, overview, posterPath: String
    let seasonNumber: Int
}

struct LastEpisodeToAir {
    let airDate: String?
    let episodeNumber, id: Int?
    let name, overview: String?
    let seasonNumber: Int?
    let stillPath: String?
}

