//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

enum MovieEndpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case upcoming, popular
    case nowPlaying = "now_playing"
    case topRated = "top_rated"
    var sortIndex: Int {
        switch self {
        case .nowPlaying:
            return 0
        case .upcoming:
            return 1
        case .popular:
            return 2
        case .topRated:
            return 3
        }
    }
    var title: String {
        switch self {
        case .nowPlaying: return "now playing"
        case .upcoming: return "up coming"
        case .topRated: return "top rated"
        case .popular: return "popular"
        }
    }
}

enum SeriesEndpoint: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case latest
    case airingToday = "airing_today"
    case onTheAir = "on_the_air"
    var sortIndex: Int {
        switch self {
        case .latest:
            return 0
        case .airingToday:
            return 1
        case .onTheAir:
            return 2
        }
    }
    var title: String {
        switch self {
        case .latest: return "latest"
        case .airingToday: return "airing today"
        case .onTheAir: return "on the air"
        }
    }
}
