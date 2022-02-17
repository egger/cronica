//
//  Content.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation

struct ContentResponse: Decodable, Identifiable {
    let id: String?
    let results: [Content]
}

struct Content: Identifiable, Decodable {
    let id: Int
    private let title, name, overview, backdropPath, posterPath: String?
    private let runtime, numberOfEpisodes, numberOfSeasons: Int?
    private let credits: Credits?
    let similar: ContentResponse?
}

extension Content {
    var itemTitle: String {
        title ?? name!
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("No information available.", comment: "No overview provided.")
    }
    var movieRuntime: String? {
        if runtime == nil {
            return nil
        } else {
            return Util.durationFormatter.string(from: TimeInterval(runtime!) * 60)
        }
    }
}
