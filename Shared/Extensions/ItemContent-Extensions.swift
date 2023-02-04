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
        genres?.first?.name ?? NSLocalizedString("Not Available", comment: "")
    }
    var itemCountry: String? {
        return productionCountries?.first?.name ?? NSLocalizedString("Not Available", comment: "")
    }
    var itemCompany: String {
        return productionCompanies?.first?.name ?? NSLocalizedString("Not Available", comment: "")
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
            return runtime?.convertToLongRuntime()
        }
        return nil
    }
    var shortItemRuntime: String? {
        if runtime != nil && runtime! > 0 {
            return runtime?.convertToShortRuntime()
        }
        return nil
    }
    var itemInfo: String {
        if let itemTheatricalString, let shortItemRuntime {
            return "\(itemGenre) • \(itemTheatricalString) • \(shortItemRuntime)"
        }
        if let itemTheatricalString {
            return "\(itemGenre) • \(itemTheatricalString)"
        }
        if let date = nextEpisodeDate {
            return "\(itemGenre) • \(date.convertDateToString())"
        }
        if let shortItemRuntime {
            return "\(itemGenre) • \(shortItemRuntime)"
        }
        if let itemFallbackDate {
            return "\(itemGenre) • \(itemFallbackDate.convertDateToString())"
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
                return "\(voteAverage.rounded())/10"
            }
        }
        return nil
    }
    var itemNotificationID: String {
        return "\(id)@\(itemContentMedia.toInt)"
    }
    var posterImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
    var posterImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: posterPath)
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
    var cardImageOriginal: URL? {
        return NetworkService.urlBuilder(size: .original, path: backdropPath)
    }
    var castImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var imdbUrl: URL? {
        guard let imdbId else { return nil }
        return URL(string: "https://www.imdb.com/title/\(imdbId)")
    }
    var hasIMDbUrl: Bool {
        if imdbId != nil { return true }
        return false
    }
    var itemSearchDescription: String {
        if media == .person {
            return media.title
        }
        if itemTheatricalString != nil && shortItemRuntime != nil {
            return "\(itemContentMedia.title) • \(itemTheatricalString!)"
        }
        if let itemTheatricalString {
            return "\(itemContentMedia.title) • \(itemTheatricalString)"
        }
        if let date = nextEpisodeDate {
            return "\(itemContentMedia.title) • \(date.convertDateToString())"
        }
        if let itemFallbackDate {
            return "\(itemContentMedia.title) • \(itemFallbackDate.convertDateToString())"
        }
        if let date = lastEpisodeToAir?.airDate {
            let formattedDate = date.convertStringToDate()
            if let formattedDate {
                return "\(itemContentMedia.title) • \(formattedDate.convertDateToString())"
            }
        }
        return "\(itemContentMedia.title)"
    }
    var itemImage: URL? {
#if os(tvOS)
        switch media {
        case .person: return castImage
        default: return posterImageMedium
        }
#else
        switch media {
        case .person: return castImage
        default: return cardImageMedium
        }
#endif
    }
    var itemTrailers: [VideoItem]? {
        return NetworkService.fetchVideos(for: videos?.results)
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/\(itemContentMedia.rawValue)/\(id)")!
    }
    var itemSearchURL: URL {
        return URL(string: "https://www.themoviedb.org/\(media.rawValue)/\(id)")!
    }
    var itemSeasons: [Int]? {
        guard let numberOfSeasons else { return nil }
        return Array(1...numberOfSeasons)
    }
    var nextEpisodeDate: Date? {
        if let nextEpisodeDate = nextEpisodeToAir?.airDate {
            return nextEpisodeDate.convertStringToDate()
        }
        return nil
    }
    var itemTheatricalString: String? {
        if let dates = releaseDates?.results {
            return dates.toReleasedDateFormatted()
        }
        if let date = nextEpisodeDate {
            return "\(date.convertDateToString())"
        }
        return nil
    }
    var itemTheatricalDate: Date? {
        if let itemTheatricalString {
            return itemTheatricalString.convertStringToDate()
        }
        if let releaseDate = releaseDate {
            return releaseDate.convertStringToDate()
        }
        return nil
    }
    var itemFallbackDate: Date? {
        if let itemTheatricalDate {
            return itemTheatricalDate
        }
        if let releaseDate = releaseDate {
            return releaseDate.convertStringToDate()
        }
        if let lastEpisodeToAir {
            if let date = lastEpisodeToAir.airDate {
                return date.convertStringToDate()
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
