//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

enum ContentEndpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case upcoming, popular, latest
    case nowPlaying = "now_playing"
    var sortIndex: Int {
        switch self {
        case .upcoming:
            return 0
        case .popular:
            return 1
        case .latest:
            return 2
        case .nowPlaying:
            return 3
        }
    }
    var title: String {
        switch self {
        case .upcoming:
            return "Up Coming"
        case .popular:
            return "Popular"
        case .latest:
            return "Latest"
        case .nowPlaying:
            return "Now Playing"
        }
    }
}
