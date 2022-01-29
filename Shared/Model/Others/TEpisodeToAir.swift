//
//  TEpisodeToAir.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

struct TEpisodeToAir: Decodable, Identifiable {
    let airDate: String?
    let id: Int
    let episodeNumber: Int?
    let name, overview, productionCode: String?
    let seasonNumber: Int?
    let stillPath: String?
    let voteAverage: Double?
    let voteCount: Int?
}
