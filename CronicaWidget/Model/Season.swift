//
//  Season.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import Foundation

struct Season: Decodable, Identifiable, Hashable {
    let id, seasonNumber: Int
    let airDate: String?
}

struct Episode: Decodable {
    var id: Int?
}
