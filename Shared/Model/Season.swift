//
//  Season.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation
import SwiftUI

/// A model that represents a TV Show's season.
struct Season: Codable, Identifiable, Hashable {
    let id, seasonNumber: Int
    let name, overview: String?
    let episodes: [Episode]?
    let airDate: String?
    let posterPath: String?
}
/// A model that represents an episode.
struct Episode: Identifiable, Codable, Hashable {
    let id: Int
    let episodeNumber, seasonNumber: Int?
    let name, overview, stillPath, airDate: String?
}

extension Season {
    var seasonPosterUrl: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
    
    var itemDate: String? {
        if let airDate, let date = airDate.toDate() {
            return date.convertDateToString()
        }
        return nil
    }
}
