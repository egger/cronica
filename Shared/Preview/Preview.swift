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
extension Content {
    static var previewContents: [Content] {
        let data: ContentResponse? = try? Bundle.main.decode(from: "movies")
        return data!.results
    }
    static var previewContent: Content {
        previewContents[0]
    }
}
extension Credits {
    static var previewCredits: Credits {
        return Movie.previewMovie.credits!
    }
    static var previewCast: Person {
        return previewCredits.cast[2]
    }
    static var previewCrew: Person {
        return previewCredits.crew[0]
    }
}
