//
//  TMDB.swift
//  Story
//
//  Created by Alexandre Madeira on 21/04/23.
//

import Foundation

struct RequestTokenTMDB: Codable {
    var statusMessage: String?
    var requestToken: String?
    var success: Bool?
    var statusCode: Int?
}

struct AccessTokenTMDB: Codable {
    var statusMessage: String?
    var accessToken: String?
    var success: Bool?
    var statusCode: Int?
    var accountId: String?
}

struct TMDBList: Codable {
    var page: Int?
    var totalResults: Int?
    var totalPages: Int?
    var results: [TMDBListResult]?
}

struct TMDBListResult: Codable, Identifiable, Hashable {
    let id: Int
    var name: String?
}

extension TMDBListResult {
    var itemTitle: String {
        return name ?? NSLocalizedString("Not Found", comment: "")
    }
}

struct DetailedTMDBList: Identifiable, Codable {
    var id: Int
    var runtime, totalPages, totalResults: Int?
    var sortBy: String?
    var results: [ItemContent]?
}

struct TMDBWatchlist: Codable {
    var page: Int?
    var totalPages: Int?
    var results: [ItemContent]?
}

extension TMDBWatchlist {
    var itemTotalPages: Int {
        totalPages ?? 1
    }
}

struct TMDBItemContent: Codable {
    var media_type: String
    var media_id: Int
}

struct TMDBItem: Codable {
    var items: [TMDBItemContent]
}

struct TMDBv3: Codable {
    var success: Bool?
    var sessionId: String?
}

struct TMDBWatchlistItemV3: Codable {
    var media_type: String
    var media_id: Int
    var watchlist: Bool
}

struct TMDBNewList: Codable {
    var id: Int
}
