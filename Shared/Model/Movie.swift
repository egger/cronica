//
//  Movie.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import Foundation

struct Response: Decodable, Identifiable {
    let id: String?
    let results: [Movie]
}

struct Section: Identifiable {
    var id = UUID()
    let movies: [Movie]
    let endpoint: MovieEndpoints
    var title: String {
        endpoint.title
    }
    var thumbnailType: String {
        switch endpoint {
        case .upcoming:
            return "card"
        case .popular:
            return "poster"
        case .nowPlaying:
            return "poster"
        case .topRated:
            return "poster"
        }
    }
}

struct Movie: Decodable, Identifiable, Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: Int
    let title: String
    let overview: String?
    private let posterPath, backdropPath: String
    let homepage: String?
    let popularity: Double?
    private let releaseDate: String?
    private let runtime: Int?
    let status, tagline: String?
    let genres: [Genre]?
    var w500PosterImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath)")!
    }
    var originalPosterImage: URL {
        return URL(string: "\(ApiConstants.originalImageUrl)\(posterPath)")!
    }
    var backdropImage: URL {
        return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath)")!
    }
    var movieRuntime: String {
        return Util.durationFormatter.string(from: TimeInterval(runtime!) * 60) ?? "n/a"
    }
    let credits: Credits?
}
