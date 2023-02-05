//
//  DiscoverSortBy.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 27/01/23.
//

import Foundation

enum DiscoverSortBy: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case popularityDesc = "popularity.desc"
    case popularityAsc = "popularity.asc"
    case releaseDateDesc = "released_date.desc"
    case releasedDateAsc = "released_date.asc"
    case voteAverageDesc = "vote_average.desc"
    case voteAverageAsc = "vote_average.asc"
}
