//
//  Preview.swift
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
}

extension Credits {
    static var previewCredits: Credits {
        return Movie.previewMovie.credits!
    }
    static var previewCast: Cast {
        return previewCredits.cast[2]
    }
    static var previewCrew: Crew {
        return previewCredits.crew[0]
    }
}
