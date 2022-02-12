//
//  Movie.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import Foundation

struct MovieResponse: Decodable, Identifiable {
    let id: String?
    let results: [Movie]
}

struct MovieSection: Identifiable {
    var id = UUID()
    let results: [Movie] 
    let endpoint: MovieEndpoints
    var title: String {
        endpoint.title
    }
    var style: String {
        switch endpoint {
        case .upcoming:
            return "poster"
        case .popular:
            return "poster"
        case .nowPlaying:
            return "card"
        }
    }
}

struct Movie: Decodable, Identifiable {
    let id: Int
    let title, overview: String
    private let posterPath, backdropPath: String
    private let releaseDate: String?
    private let runtime: Int?
    let status, tagline, homepage: String?
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
    var release: String {
        guard let releaseDate = self.releaseDate, let date = Util.dateFormatter.date(from: releaseDate) else {
            return "n/a"
        }
        return Util.dateString.string(from: date)
    }
    var link: URL {
        return URL(string: "https://themoviedb.org/movie/\(id)")!
    }
    let credits: Credits?
    let similar: MovieResponse?
}
