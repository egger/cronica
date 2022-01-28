//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
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
        case .topRated:
            return 2
        case .popular:
            return 3
        }
    }
    
    var title: String {
        switch self {
        case .nowPlaying: return "now playing"
        case .upcoming: return "upcoming"
        case .topRated: return "top rated"
        case .popular: return "popular"
        }
    }
}

enum TvEndpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case latest
    case airingToday = "airing_today"
    case onTheAir = "on_the_air"
}
