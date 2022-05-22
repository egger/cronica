//
//  TrackedSeasons.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/05/22.
//

import Foundation

struct TrackedSeasons: Identifiable {
    var id = UUID()
    let results: [TrackedSeason]?
}

struct TrackedSeason: Identifiable {
    var id = UUID()
    let season: [String: [Int]]
}
