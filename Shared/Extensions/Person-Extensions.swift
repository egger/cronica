//
//  Person-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/03/22.
//

import Foundation

extension Person {
    var itemImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var itemBiography: String {
        biography ?? NSLocalizedString("Not Available",
                                       comment: "Missing Biography")
    }
    var itemRole: String? {
        job ?? character
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/person/\(id)")!
    }
}
extension Filmography {
    var itemTitle: String {
        title ?? name!
    }
    var itemImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
    var itemMedia: MediaType {
        switch mediaType {
        case "movie": return .movie
        case "tv": return .tvShow
        default: return .movie
        }
    }
}
