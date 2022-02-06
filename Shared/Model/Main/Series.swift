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

struct Series: Decodable, Identifiable {
    let id: Int
    private let name: String
    let overview: String
    private let posterPath, backdropPath: String?
    let firstAirDate: String?
    var posterImage: URL? {
        if posterPath != nil {
            return URL(string: "\(ApiConstants.originalImageUrl)\(posterPath!)")!
        } else {
            return nil
        }
    }
    var backdropImage: URL? {
        if backdropPath != nil {
            return URL(string: "\(ApiConstants.originalImageUrl)\(backdropPath!)")!
        } else {
            return nil
        }
    }
    var title: String {
        return name
    }
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case id, name, overview
        case posterPath = "poster_path"
    }
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
