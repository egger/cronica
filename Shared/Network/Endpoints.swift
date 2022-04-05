//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

enum Endpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case upcoming
    case nowPlaying = "now_playing"
    case onTheAir = "on_the_air"
    var sortIndex: Int {
        switch self {
        case .upcoming:
            return 0
        case .nowPlaying:
            return 1
        case .onTheAir:
            return 2
        }
    }
    var title: String {
        switch self {
        case .upcoming:
            return "Up Coming"
        case .nowPlaying:
            return "Latest Movies"
        case .onTheAir:
            return "Latest Shows"
        }
    }
    var subtitle: String {
        switch self {
        case .upcoming:
            return "Upcoming Movies"
        case .nowPlaying:
            return ""
        case .onTheAir:
            return ""
        }
    }
    var image: String {
        switch self {
        case .upcoming:
            return "theatermasks"
        case .nowPlaying:
            return "list.and.film"
        case .onTheAir:
            return "tv"
        }
    }
}
