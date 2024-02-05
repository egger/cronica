//
//  Endpoints.swift
//  Cronica
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

/// Endpoints represents a default list that can be fetched from TMDb.
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
        case .upcoming: return NSLocalizedString("Up Coming", comment: "")
        case .nowPlaying: return NSLocalizedString("Latest Movies", comment: "")
        }
    }
    var subtitle: String {
        switch self {
        case .upcoming: return NSLocalizedString("Coming Soon To Theaters", comment: "")
        case .nowPlaying: return NSLocalizedString("Recently Released", comment: "")
        }
    }
    var type: MediaType {
        switch self {
        case .upcoming: return .movie
        case .nowPlaying: return .movie
        }
    }
}
