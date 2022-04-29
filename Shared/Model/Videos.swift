//
//  Videos.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Videos: Decodable {
    let results: [VideosResult]
}
struct VideosResult: Decodable {
    let iso639_1, iso3166_1, publishedAt, id: String?
    let name, key, type: String
    let official: Bool
}
