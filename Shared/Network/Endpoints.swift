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
    var sortIndex: Int {
        switch self {
        case .upcoming: return 0
        case .nowPlaying: return 1
        }
    }
    var title: String {
        switch self {
        case .upcoming: return "Up Coming"
        case .nowPlaying: return "Latest Movies"
        }
    }
    var subtitle: String {
        switch self {
        case .upcoming: return "Releasing Soon"
        case .nowPlaying: return "Recently Released"
        }
    }
    var image: String {
        switch self {
        case .upcoming: return "theatermasks"
        case .nowPlaying: return "list.and.film"
        }
    }
}
