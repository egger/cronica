//
//  Content-Helpers.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

extension Content {
    //MARK: String
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
    var itemRuntime: String? {
        if runtime != nil && runtime! > 0 {
            return Utilities.durationFormatter.string(from: TimeInterval(runtime!) * 60)
        }
        return nil
    }
    var theatricalDate: String? {
        if let dates = releaseDates {
            let date = Utilities.getReleaseDate(results: dates.results)
            return date ?? NSLocalizedString("",
                                             comment: "API didn't provided status information.")
        }
        return nil
    }
    var itemInfo: String {
        if let date = theatricalDate {
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
        } else {
            return nil
        }
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
    var itemRelease: Date? {
        if let theatricalDate = theatricalDate {
            return Utilities.dateFormatter.date(from: theatricalDate)
        }
        if let releaseDate = releaseDate {
            return Utilities.dateFormatter.date(from: releaseDate)
        }
        return nil
    }
    var nextEpisodeDate: Date? {
        if let nextEpisodeDate = nextEpisodeToAir?.airDate {
            return Utilities.dateFormatter.date(from: nextEpisodeDate)
        }
        return nil
    }
    var itemCanNotify: Bool {
        if let date = itemRelease {
            if date > Date() { return true }
        }
        if let date = nextEpisodeDate {
            if date > Date() { return true }
        }
        return false
    }
    /// This MediaType value is only used on regular content, such a trending list, filmography.
    ///
    /// Change to media to search results.
    var itemContentMedia: MediaType {
        if title != nil {
            return MediaType.movie
        } else {
            return MediaType.tvShow
        }
    }
    /// This MediaType value is only used on search results
    ///
    /// Change to itemContentMedia to specify on normal usage.
    var media: MediaType {
        switch mediaType {
        case "tv": return MediaType.tvShow
        case "movie": return MediaType.movie
        case "person": return MediaType.person
        default: return MediaType.movie
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
        name ?? "Not Available"
    }
    var itemAbout: String {
        overview ?? "Not Available"
    }
    var itemImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: stillPath)
    }
    var itemImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: stillPath)
    }
}
