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











// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)
//
//import Foundation
//
//// MARK: - Welcome
//struct Welcome: Codable {
//    let page: Int
//    let results: [Result]
//    let totalPages, totalResults: Int
//
//    enum CodingKeys: String, CodingKey {
//        case page, results
//        case totalPages = "total_pages"
//        case totalResults = "total_results"
//    }
//}
//
//// MARK: - Result
struct Series: Decodable, Identifiable {
    let backdropPath: String?
    let firstAirDate: String
    let genreIDS: [Int]
    let id: Int
    let name: String
    let originCountry: [String]
    let originalLanguage, originalName, overview: String
    let popularity: Double
    let posterPath: String
    let voteAverage: Double
    let voteCount: Int
    var posterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
    }
    var backdropImage: URL {
        return URL(string: "\(ApiConstants.w1066ImageUrl)\(String(describing: backdropPath))")!
    }
    var title: String {
        return name
    }
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case genreIDS = "genre_ids"
        case id, name
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
