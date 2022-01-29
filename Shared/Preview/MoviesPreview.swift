//
//  MoviesPreview.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import Foundation

extension Movie {
    static var previewMovies: [Movie] {
        let data: MovieResponse? = try? Bundle.main.decode(from: "movies")
        return data!.results
    }
    static var previewMovie: Movie {
        previewMovies[0]
    }
    static var previewCredits: [Cast] {
        let data: Credits? = try? Bundle.main.decode(from: "cast")
        return data!.cast
    }
    static var previewCast: Cast {
        previewCredits[0]
    }
}
