//
//  Videos.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Videos: Decodable, Hashable {
    let results: [VideosResult]
}
struct VideosResult: Decodable, Hashable {
    let iso639_1, iso3166_1, id: String?
    let name, key, type: String
    let official: Bool
}
