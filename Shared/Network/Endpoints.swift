//
//  Endpoints.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

enum Endpoints: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case upcoming, latest
    case nowPlaying = "now_playing"
    var sortIndex: Int {
        switch self {
        case .upcoming:
            return 0
        case .latest:
            return 1
        case .nowPlaying:
            return 2
        }
    }
    var title: String {
        switch self {
        case .upcoming:
            return "Up Coming"
        case .latest:
            return "Latest"
        case .nowPlaying:
            return "Latest Releases"
        }
    }
}
