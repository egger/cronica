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

struct TMDBListResult: Codable, Identifiable {
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
    var runtime: Int?
    var results: [ItemContent]?
}

struct TMDBWatchlist: Codable {
    var page: Int?
    var totalPages: Int?
    var results: [ItemContent]?
}
