//
//  Season.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Season: Decodable, Identifiable {
    let id, seasonNumber: Int
    let episodeCount: Int?
    let episodes: [Episode]?
    let name, overview, posterPath, airDate: String?
}
