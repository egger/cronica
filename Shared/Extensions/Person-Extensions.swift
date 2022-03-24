//
//  Person-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/03/22.
//

import Foundation

extension Person {
    var itemImage: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: profilePath)
    }
    var itemBiography: String {
        biography ?? NSLocalizedString("Not Available",
                                       comment: "Missing Biography")
    }
    var itemRole: String? {
        job ?? character
    }
}
extension Filmography {
    var itemTitle: String {
        title ?? NSLocalizedString("Title not found",
                                   comment: "Missing Title")
    }
    var itemImage: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: posterPath)
    }
    var itemMedia: MediaType {
        switch media_type {
        case "movie":
            return MediaType.movie
        case "tv":
            return MediaType.tvShow
        default:
            return MediaType.movie
        }
    }
}
