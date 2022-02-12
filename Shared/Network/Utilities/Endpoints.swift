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
    //case topRated = "top_rated"
    var sortIndex: Int {
        switch self {
        case .nowPlaying:
            return 0
        case .upcoming:
            return 1
        case .popular:
            return 2
//        case .topRated:
//            return 3
        }
    }
    var title: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Up Coming"
        //case .topRated: return "Top Rated"
        case .popular: return "Popular"
        }
    }
}

enum SeriesEndpoint: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case latest, popular
    case airingToday = "airing_today"
    case onTheAir = "on_the_air"
    var sortIndex: Int {
        switch self {
        case .popular:
            return 0
        case .latest:
            return 1
        case .airingToday:
            return 2
        case .onTheAir:
            return 3
        
        }
    }
    var title: String {
        switch self {
        case .latest: return "Latest"
        case .airingToday: return "Airing Today"
        case .onTheAir: return "On The Air"
        case .popular: return "Popular"
        }
    }
}
