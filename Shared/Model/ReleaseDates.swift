//
//  ReleaseDates.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct ReleaseDates: Decodable {
    let results: [ReleaseDatesResult]
}
struct ReleaseDatesResult: Decodable {
    let iso31661: String?
    let releaseDates: [ReleaseDate]?
}
struct ReleaseDate: Decodable {
    let certification, iso6391, releaseDate: String?
    let type: Int?
}
