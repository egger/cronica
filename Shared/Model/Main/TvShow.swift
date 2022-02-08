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
            return "poster"
        case .onTheAir:
            return "card"
        case .airingToday:
            return "poster"
        }
    }
}

struct TvShow: Decodable, Identifiable {
    let id: Int
    let name: String
    let posterPath: String
    let backdropPath: String?
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
        
