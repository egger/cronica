//
//  Season.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Season: Decodable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int?
    let episodes: [Episode]?
    let name, overview, posterPath: String?
    let seasonNumber: Int
}
