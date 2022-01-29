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
        let data: Credits? = try? Bundle.main.decode(from: "credits")
        return data!
    }
    static var previewCast: Cast {
        let data = previewCredits.cast[0]
        return data
    }
}

extension Series {
    static var previewSeries: [Series] {
        let data: SeriesResponse? = try? Bundle.main.decode(from: "series")
        return data!.results
    }
    static var previewSerie: Series {
        previewSeries[1]
    }
}
