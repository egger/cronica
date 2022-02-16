//
//  TVShow.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import Foundation

struct TvResponse: Decodable, Identifiable {
    let id: String?
    let results: [TVShow]
}

struct TVSection: Identifiable {
    var id = UUID()
    let results: [TVShow]
    let endpoint: SeriesEndpoint
    var title: String {
        endpoint.title
    }
    var style: StyleType {
        switch endpoint {
        case .latest:
            return StyleType.poster
        case .popular:
            return StyleType.card
        case .onTheAir:
            return StyleType.poster
        }
    }
}

struct TVShow: Decodable, Identifiable {
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
    let credits: Credits?
    let similar: TvResponse?
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

