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
    let results: [Content]
    
    let endpoint: MovieEndpoints
    var title: String {
        endpoint.title
    }
    var style: StyleType {
        switch endpoint {
        case .upcoming:
            return StyleType.poster
        case .popular:
            return StyleType.poster
        case .nowPlaying:
            return StyleType.card
        }
    }
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
        overview ?? NSLocalizedString("No details available.",
                                      comment: "No overview provided by the service.")
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
    var itemGenres: String? {
        if genres != nil {
            var genreArray: [String] = [""]
            for word in genres! {
                genreArray.append(word.name ?? "")
            }
            return genreArray.description
        } else {
            return nil
        }
    }
    
    var itemRuntime: String {
        return Util.durationFormatter.string(from: TimeInterval(runtime!) * 60) ?? "n/a"
    }
    var releaseDateString: String {
        guard let releaseDate = self.releaseDate, let date = Util.dateFormatter.date(from: releaseDate) else {
            return "n/a"
        }
        return Util.dateString.string(from: date)
    }
    var release: Date {
        return Util.dateFormatter.date(from: releaseDateString) ?? Date()
    }
}
