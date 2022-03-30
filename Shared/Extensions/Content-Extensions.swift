//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

extension Content {
    var itemTitle: String {
        title ?? name!
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("No details available.",
                                      comment: "No overview provided by the service.")
    }
    var itemGenre: String {
        genres?.first?.name ?? NSLocalizedString("Not Available",
                                                 comment: "")
    }
    var itemCountry: String {
        return productionCountries?.first?.name ?? NSLocalizedString("Not Available",
                                                                     comment: "")
    }
    var itemCompany: String {
        return productionCompanies?.first?.name ?? NSLocalizedString("Not Available",
                                                                     comment: "")
    }
    var itemStatus: String {
        status ?? NSLocalizedString("No information available",
                                    comment: "API didn't provided status information.")
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
    var posterImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
    var cardImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: backdropPath)
    }
    var cardImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: backdropPath)
    }
    var cardImageOriginal: URL? {
        return NetworkService.urlBuilder(size: .original, path: backdropPath)
    }
    var castImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var itemImage: URL? {
        switch media {
        case .movie:
            return cardImageMedium
        case .person:
            return castImage
        case .tvShow:
            return posterImageMedium
        }
    }
    var seasonsNumber: Int {
        if numberOfSeasons != nil && numberOfSeasons! > 0 {
            return numberOfSeasons!
        } else {
            return 0
        }
    }
    var itemContentMedia: MediaType {
        if title != nil {
            return MediaType.movie
        } else {
            return MediaType.tvShow
        }
    }
    var itemRuntime: String {
        if runtime != nil && runtime! > 0 {
            return Utilities.durationFormatter.string(from: TimeInterval(runtime!) * 60)!
        } else {
            return NSLocalizedString("No information available",
                                     comment: "API didn't provided status information.")
        }
    }
    var theatricalReleaseDate: String {
        if let dates = releaseDates {
            let date = Utilities.getReleaseDate(results: dates.results)
            return date ?? NSLocalizedString("",
                                             comment: "API didn't provided status information.")
        } else {
            return NSLocalizedString("",
                                     comment: "API didn't provided status information.")
        }
    }
    var itemReleaseDate: Date {
        let date = Utilities.dateFormatter.date(from: theatricalReleaseDate)
        print("itemReleaseDate: \(date as Any)")
        return date ?? Date()
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
    var itemInfo: String {
        if !itemGenre.isEmpty && !theatricalReleaseDate.isEmpty {
            return "\(itemGenre), \(theatricalReleaseDate)"
        }
        else if !itemGenre.isEmpty {
            return "\(itemGenre)"
        }
        else {
            return ""
        }
    }
    var itemCanNotify: Bool {
        if !isReleased {
            return true
        } else {
            return false
        }
    }
}
extension Season {
    var itemTitle: String {
        name ?? NSLocalizedString("Not Available",
                                  comment: "")
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("Not Available",
                                      comment: "")
    }
    var posterImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
}
extension Episode {
    var itemTitle: String {
        name ?? NSLocalizedString("Not Available",
                                  comment: "")
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("Not Available",
                                      comment: "")
    }
    var itemImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: stillPath)
    }
    var itemImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: stillPath)
    }
}
