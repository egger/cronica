//
//  Content.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation

struct ContentResponse: Identifiable, Decodable {
    let id: String?
    let results: [Content]
}

struct ContentSection: Identifiable {
    var id = UUID()
}

struct Content: Identifiable, Decodable {
    let id: Int
    private let title, name, overview: String?
    private let posterPath, backdropPath: String?
    private let releaseDate: String?
    private let runtime: Int?
    let genres: [Genre]?
    let credits: Credits?
    let similar: ContentResponse?
}

extension Content {
    var itemTitle: String {
        title ?? name!
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("No details available.", comment: "No overview provided by the service.")
    }
    var posterImage500: URL? {
        if posterPath != nil {
            return URL(string: "\(ApiConstants.w500ImageUrl)\(posterPath!)")!
        } else {
            return nil
        }
    }
    var cardImage: URL? {
        if backdropPath != nil {
            return URL(string: "\(ApiConstants.w1066ImageUrl)\(backdropPath!)")!
        } else {
            return nil
        }
    }
}
