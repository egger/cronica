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
    var sortIndex: Int {
        switch self {
        case .nowPlaying:
            return 0
        case .upcoming:
            return 1
        case .popular:
            return 2
        }
    }
    var title: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Up Coming"
        case .popular: return "Popular"
        }
    }
}

enum SeriesEndpoint: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case latest, popular
    case onTheAir = "on_the_air"
    var sortIndex: Int {
        switch self {
        case .popular:
            return 0
        case .latest:
            return 1
        case .onTheAir:
            return 2
        }
    }
    var title: String {
        switch self {
        case .latest:
            return "Latest"
        case .onTheAir:
            return "On The Air"
        case .popular:
            return "Popular"
        }
    }
}
