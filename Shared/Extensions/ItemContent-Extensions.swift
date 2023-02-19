//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

extension ItemContent {
    // MARK: Strings
    var itemTitle: String {
        if let title { return title }
        if let name { return name }
        return NSLocalizedString("Not Available", comment: "")
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
        if let genre = genres?.first?.name { return genre }
        return NSLocalizedString("Not Available", comment: "")
    }
    var itemCountry: String {
        if let country = productionCountries?.first?.name { return country }
        return NSLocalizedString("Not Available", comment: "")
    }
    var itemCompany: String {
        if let company = productionCompanies?.first?.name {
            return company
        }
        return NSLocalizedString("Not Available", comment: "")
    }
    var itemRuntime: String? {
        if let runtime {
            if runtime > 0 { return runtime.convertToLongRuntime() }
        }
        return nil
    }
    var shortItemRuntime: String? {
        if let runtime {
            if runtime > 0 { return runtime.convertToShortRuntime() }
        }
        return nil
    }
    var itemNotificationID: String {
        return "\(id)@\(itemContentMedia.toInt)"
    }
    var itemTheatricalString: String? {
        if let dates = releaseDates?.results {
            return DatesManager.getReleaseDateFormatted(results: dates)
        }
        if let date = nextEpisodeDate {
            return "\(DatesManager.dateString.string(from: date))"
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
            return "\(itemGenre) • \(DatesManager.dateString.string(from: date))"
        }
        if let shortItemRuntime {
            return "\(itemGenre) • \(shortItemRuntime)"
        }
        if let itemFallbackDate {
            return "\(itemGenre) • \(DatesManager.dateString.string(from: itemFallbackDate))"
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
                return NSLocalizedString("\(voteAverage.rounded())/10", comment: "")
            }
        }
        return nil
    }
    
    // MARK: Double
    var itemPopularity: Double {
        popularity ?? 0.0
    }
    
    // MARK: Custom
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
    var itemTrailers: [VideoItem]? {
        return NetworkService.fetchVideos(for: videos?.results)
    }
    var itemCompanies: [ProductionCompany] {
        if let productionCompanies {
            return productionCompanies
        }
        return []
    }
    
    // MARK: URL
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
    var itemSearchURL: URL {
        return URL(string: "https://www.themoviedb.org/\(media.rawValue)/\(id)")!
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/\(itemContentMedia.rawValue)/\(id)")!
    }
    
    // MARK: Bool
    var hasIMDbUrl: Bool {
        if imdbId != nil { return true }
        return false
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
            return "\(itemContentMedia.title) • \(DatesManager.dateString.string(from: date))"
        }
        if let itemFallbackDate {
            return "\(itemContentMedia.title) • \(DatesManager.dateString.string(from: itemFallbackDate))"
        }
        if let date = lastEpisodeToAir?.airDate {
            let formattedDate = DatesManager.dateFormatter.date(from: date)
            if let formattedDate {
                return "\(itemContentMedia.title) • \(DatesManager.dateString.string(from: formattedDate))"
            }
        }
        return "\(itemContentMedia.title)"
    }

    
    
    // MARK: Int
    var itemSeasons: [Int]? {
        guard let numberOfSeasons else { return nil }
        return Array(1...numberOfSeasons)
    }
    
    // MARK: Date
    var nextEpisodeDate: Date? {
        if let nextEpisodeDate = nextEpisodeToAir?.airDate {
            return DatesManager.dateFormatter.date(from: nextEpisodeDate)
        }
        return nil
    }
    var itemTheatricalDate: Date? {
        if let itemTheatricalString {
            return DatesManager.dateString.date(from: itemTheatricalString)
        }
        if let releaseDate = releaseDate {
            return DatesManager.dateFormatter.date(from: releaseDate)
        }
        return nil
    }
    var itemFallbackDate: Date? {
        if let itemTheatricalDate {
            return itemTheatricalDate
        }
        if let releaseDate = releaseDate {
            return DatesManager.dateFormatter.date(from: releaseDate)
        }
        if let lastEpisodeToAir {
            if let date = lastEpisodeToAir.airDate {
                return DatesManager.dateFormatter.date(from: date)
            }
        }
        return nil
    }
    
    // MARK: Preview
    static var previewContents: [ItemContent] {
        let data: ItemContentResponse? = try? Bundle.main.decode(from: "content")
        return data!.results
    }
    static var previewContent: ItemContent {
        previewContents[0]
    }
}
