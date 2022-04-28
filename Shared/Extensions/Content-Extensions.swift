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
    var itemStatus: ContentSchedule {
        switch status {
        case "Rumored": return .production
        case "Planned": return .production
        case "In Production": return .soon
        case "Post Production": return .soon
        case "Returning Series": return .soon
        case "Released": return .released
        case "Ended": return .released
        case "Canceled": return .cancelled
        default: return .unknown
        }
    }
    var itemRuntime: String? {
        if runtime != nil && runtime! > 0 {
            return Utilities.durationFormatter.string(from: TimeInterval(runtime!) * 60)
        }
        return nil
    }
    var itemInfo: String {
        if let date = itemTheatricalString {
            return "\(itemGenre), \(date)"
        }
        if let date = nextEpisodeDate {
            return "\(itemGenre), \(Utilities.dateString.string(from: date))"
        }
        if !itemGenre.isEmpty { return "\(itemGenre)" }
        return ""
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
    var castImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var itemImage: URL? {
        switch media {
        case .movie: return cardImageMedium
        case .person: return castImage
        case .tvShow: return posterImageMedium
        }
    }
    var itemTrailer: URL? {
        if let videos = videos {
            return Utilities.getTrailer(videos: videos.results)
        }
        return nil
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/\(itemContentMedia.rawValue)/\(id)")!
    }
    var seasonsNumber: Int {
        if numberOfSeasons != nil && numberOfSeasons! > 0 {
            return numberOfSeasons!
        }
        return 0
    }
    var nextEpisodeDate: Date? {
        if let nextEpisodeDate = nextEpisodeToAir?.airDate {
            return Utilities.dateFormatter.date(from: nextEpisodeDate)
        }
        return nil
    }
    var itemTheatricalString: String? {
        if let dates = releaseDates?.results {
            return Utilities.getReleaseDate(results: dates)
        }
        return nil
    }
    var itemTheatricalDate: Date? {
        if let date = itemTheatricalString {
            return Utilities.dateString.date(from: date)
        }
        return nil
    }
    var itemFallbackDate: Date? {
        if let releaseDate = releaseDate {
            return Utilities.dateFormatter.date(from: releaseDate)
        }
        return nil
    }
    var itemCanNotify: Bool {
        if let date = itemTheatricalDate {
            if date > Date() {
                return true
            }
        }
        if let date = nextEpisodeDate {
            if date > Date() {
                return true
            }
        }
        return false
    }
    /// This MediaType value is only used on regular content, such a trending list, filmography.
    ///
    /// Change to media to search results.
    var itemContentMedia: MediaType {
        if title != nil {
            return .movie
        } else {
            return .tvShow
        }
    }
    /// This MediaType value is only used on search results
    ///
    /// Change to itemContentMedia to specify on normal usage.
    var media: MediaType {
        switch mediaType {
        case "tv": return .tvShow
        case "movie": return .movie
        case "person": return .person
        default: return .movie
        }
    }
}
