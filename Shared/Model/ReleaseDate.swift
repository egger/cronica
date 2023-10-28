//
//  ReleaseDate.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import Foundation

struct ReleaseDates: Codable, Hashable {
    let results: [ReleaseDatesResult]
}
struct ReleaseDatesResult: Codable, Hashable {
    let iso31661: String?
    let releaseDates: [ReleaseDate]?
}
struct ReleaseDate: Codable, Hashable {
    let certification, iso6391, releaseDate: String?
    let type: Int?
}
