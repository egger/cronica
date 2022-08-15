//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

extension ItemContent {
    var itemTitle: String {
        title ?? name!
    }
    var itemOverview: String {
        if let overview {
            if overview.isEmpty {
                return NSLocalizedString("No information available.", comment: "")
            } else {
                return overview
            }
        }
        return NSLocalizedString("No information available.", comment: "")
    }
    var itemGenre: String {
        genres?.first?.name ?? "Not Available"
    }
    var itemCountry: String? {
        return productionCountries?.first?.name ?? "Not Available"
    }
    var itemCompany: String {
        return productionCompanies?.first?.name ?? "Not Available"
    }
    var itemPopularity: Double {
        popularity ?? 0.0
    }
    var itemStatus: ItemSchedule {
        if status == "Released" && itemCanNotify { return .soon }
        switch status {
        case "Rumored": return .production
        case "Planned": return .production
        case "In Production": return .soon
        case "Post Production": return .soon
        case "Returning Series": return .renewed
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
    var shortItemRuntime: String? {
        if runtime != nil && runtime! > 0 {
            return Utilities.shortDurationFormatter.string(from: TimeInterval(runtime!) * 60)
        }
        return nil
    }
    var itemInfo: String {
        if itemTheatricalString != nil && shortItemRuntime != nil {
            return "\(itemGenre) • \(itemTheatricalString!) • \(shortItemRuntime!)"
        }
        if let itemTheatricalString {
            return "\(itemGenre) • \(itemTheatricalString)"
        }
        if let date = nextEpisodeDate {
            return "\(itemGenre) • \(Utilities.dateString.string(from: date))"
        }
        if let shortItemRuntime {
            return "\(itemGenre) • \(shortItemRuntime)"
        }
        if let itemFallbackDate {
            return "\(itemGenre) • \(Utilities.dateString.string(from: itemFallbackDate))"
        }
        if !itemGenre.isEmpty { return "\(itemGenre)" }
        return ""
    }
    var itemUrlProxy: String {
        return  "https://www.themoviedb.org/\(itemContentMedia.rawValue)/\(id)"
    }
    var itemRating: String? {
        if let voteAverage {
            if voteAverage <= 0.9 {
                return nil
            } else {
                return "\(voteAverage.rounded()) out of 10"
            }
        }
        return nil
    }
    var posterImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
    var cardImageSmall: URL? {
        return NetworkService.urlBuilder(size: .small, path: backdropPath)
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
        case .person: return castImage
        default: return cardImageMedium
        }
    }
    var itemTrailers: [VideoItem]? {
        return TrailerUtilities.fetch(for: videos?.results)
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/\(itemContentMedia.rawValue)/\(id)")!
    }
    var itemSearchURL: URL {
        return URL(string: "https://www.themoviedb.org/\(media.rawValue)/\(id)")!
    }
    var itemSeasons: [Int]? {
        if let numberOfSeasons {
            return Array(1...numberOfSeasons)
        }
        return nil
    }
    var nextEpisodeDate: Date? {
        if let nextEpisodeDate = nextEpisodeToAir?.airDate {
            return Utilities.dateFormatter.date(from: nextEpisodeDate)
        }
        return nil
    }
    var itemTheatricalString: String? {
        if let dates = releaseDates?.results {
            return Utilities.getReleaseDateFormatted(results: dates)
        }
        if let date = nextEpisodeDate {
            return "\(Utilities.dateString.string(from: date))"
        }
        return nil
    }
    var itemTheatricalDate: Date? {
        if let itemTheatricalString {
            return Utilities.dateString.date(from: itemTheatricalString)
        }
        return nil
    }
    var itemFallbackDate: Date? {
        if let releaseDate = releaseDate {
            return Utilities.dateFormatter.date(from: releaseDate)
        }
        if let lastEpisodeToAir {
            if let date = lastEpisodeToAir.airDate {
                return Utilities.dateFormatter.date(from: date)
            }
        }
        return nil
    }
    var itemCanNotify: Bool {
        if let itemTheatricalDate {
            if itemTheatricalDate > Date() {
                return true
            }
        }
        if let nextEpisodeDate {
            if nextEpisodeDate > Date() {
                return true
            }
        }
        return false
    }
    var hasUpcomingSeason: Bool {
        if let nextEpisodeToAir {
            if nextEpisodeToAir.episodeNumber == 1 && itemCanNotify {
                return true
            }
        }
        return false
    }
    var itemIsAdult: Bool {
        adult ?? false
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
    static var previewContents: [ItemContent] {
        let data: ItemContentResponse? = try? Bundle.main.decode(from: "content")
        return data!.results
    }
    static var previewContent: ItemContent {
        previewContents[0]
    }
}
