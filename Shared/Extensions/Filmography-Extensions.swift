//
//  Filmography-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

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
    var itemPopularity: Double {
        popularity ?? 0.0
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/\(itemMedia.rawValue)/\(id)")!
    }
}
