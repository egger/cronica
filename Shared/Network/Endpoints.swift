//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

/// Endpoints represents a default list that can be fetched from TMDb.
enum Endpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case upcoming
    case nowPlaying = "now_playing"
    case onTheAir = "on_the_air"
    var sortIndex: Int {
        switch self {
        case .upcoming: return 0
        case .nowPlaying: return 1
        case .onTheAir: return 2
        }
    }
    var title: String {
        switch self {
        case .upcoming: return "Up Coming"
        case .nowPlaying: return "Latest Movies"
        case .onTheAir: return "Upcoming Episodes"
        }
    }
    var subtitle: String {
        switch self {
        case .upcoming: return "Releasing Soon"
        case .nowPlaying: return "Recently Released"
        case .onTheAir: return "Arriving Soon"
        }
    }
    var image: String {
        switch self {
        case .upcoming: return "theatermasks"
        case .nowPlaying: return "list.and.film"
        case .onTheAir: return "tv"
        }
    }
    var type: MediaType {
        switch self {
        case .upcoming: return .movie
        case .nowPlaying: return .movie
        case .onTheAir: return .tvShow
        }
    }
}
