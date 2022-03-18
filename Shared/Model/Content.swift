//
//  Content.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation
import SwiftUI

struct ContentResponse: Identifiable, Decodable {
    let id: String?
    let results: [Content]
}

struct ContentSection: Identifiable {
    var id = UUID()
    let results: [Content]
    let endpoint: ContentEndpoints
    var title: String {
        endpoint.title
    }
    var style: StyleType {
        switch endpoint {
        case .upcoming:
            return StyleType.card
        case .latest:
            return StyleType.poster
        case .nowPlaying:
            return StyleType.poster
        }
    }
    var headline: String {
        switch endpoint {
        case .upcoming:
            return "Movies"
        case .latest:
            return "Movies"
        case .nowPlaying:
            return "Movies"
        }
    }
}

// MARK: Content model, handles data to Movie, TV Shows, and items on Search.
struct Content: Identifiable, Decodable {
    let id: Int
    private let title, name, overview: String?
    private let posterPath, backdropPath, profilePath: String?
    private let releaseDate, status: String?
    private let runtime, numberOfEpisodes, numberOfSeasons: Int?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let genres: [Genre]?
    let credits: Credits?
    let recommendations: ContentResponse?
    private let mediaType: String?
}

// MARK: Extends Content model by handling titles, images, dates, and quick information.
extension Content {
    var itemTitle: String {
        title ?? name!
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("No details available.",
                                      comment: "No overview provided by the service.")
    }
    var seasonsNumber: Int {
        if numberOfSeasons != nil && numberOfSeasons! > 0 {
            return numberOfSeasons!
        } else {
            return 0
        }
    }
    var posterImageMedium: URL? {
        return Utilities.imageUrlBuilder(size: .medium, path: posterPath) ?? nil
    }
    var cardImageMedium: URL? {
        if backdropPath != nil {
            return Utilities.imageUrlBuilder(size: .medium, path: backdropPath!)
        } else {
            return nil
        }
    }
    var cardImageLarge: URL? {
        if backdropPath != nil {
            return Utilities.imageUrlBuilder(size: .large, path: backdropPath!)
        } else {
            return nil
        }
    }
    var cardImageOriginal: URL? {
        if backdropPath != nil {
            return Utilities.imageUrlBuilder(size: .original, path: backdropPath!)
        } else {
            return nil
        }
    }
    var personImage: URL? {
        if profilePath != nil {
            return Utilities.imageUrlBuilder(size: .medium, path: profilePath!)
        } else {
            return nil
        }
    }
    var itemGenre: String {
        genres?.first?.name ?? ""
    }
    var media: MediaType {
        switch mediaType {
        case "tv":
            return MediaType.tvShow
        case "movie":
            return MediaType.movie
        case "person":
            return MediaType.person
        default:
            return MediaType.movie
        }
    }
    var itemImage: URL? {
        switch media {
        case .movie:
            return cardImageMedium ?? nil
        case .person:
            return personImage ?? nil
        case .tvShow:
            return posterImageMedium ?? nil
        }
    }
    var itemCountry: String {
        return productionCountries?.first?.name ?? ""
    }
    var itemProduction: String {
        return productionCompanies?.first?.name ?? ""
    }
    var itemInfo: String {
        if !itemGenre.isEmpty && !itemReleaseDate.isEmpty {
            return "\(itemGenre), \(itemReleaseDate)"
        } else {
            return ""
        }
    }
    var itemContentMedia: MediaType {
        if title != nil {
            return MediaType.movie
        } else {
            return MediaType.tvShow
        }
    }
    var itemStatus: String {
        status ?? NSLocalizedString("No information available",
                                    comment: "API didn't provided status information.")
    }
    var itemRuntime: String {
        if runtime != nil {
            return Utilities.durationFormatter.string(from: TimeInterval(runtime!) * 60)!
        } else {
            return ""
        }
    }
    var itemReleaseDate: String {
        guard let releaseDate = self.releaseDate,
              let date = Utilities.dateFormatter.date(from: releaseDate) else {
                  return ""
              }
        return Utilities.dateString.string(from: date)
    }
    var release: Date {
        if releaseDate != nil && !releaseDate.isEmpty {
            return Utilities.dateFormatter.date(from: releaseDate!)!
        }
        return Date()
    }
    var isReleased: Bool {
        if Date() > release {
            return true
        } else {
            return false
        }
    }
    var itemUrl: URL? {
        return URL(string: "https://www.themoviedb.org/\(media.rawValue)/\(id)")
    }
}
