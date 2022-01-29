//
//  Season.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

struct Season: Decodable, Identifiable {
    let airDate: String?
    let episodeCount, id: Int
    let name, overview, posterPath: String
    let seasonNumber: Int
}
