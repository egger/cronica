//
//  Utilities.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import Foundation

class Utilities {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd"
        return formatter
    }()
    static let dateString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    static let userLang: String = {
        let locale = Locale.current
        guard let langCode = locale.languageCode,
              let regionCode = locale.regionCode else {
            return "en-US"
        }
        return "\(langCode)-\(regionCode)"
    }()
    static let userRegion: String = {
        guard let regionCode = Locale.current.regionCode else {
            return "US"
        }
        return regionCode
    }()
    static var releaseDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }
    static func getReleaseDate(results: [ReleaseDatesResult]) -> String? {
        for result in results {
            if result.iso31661 == Utilities.userRegion {
                if result.releaseDates != nil {
                    for date in result.releaseDates! {
                        if date.type != nil && date.type == 3 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                    }
                }
            }
        }
        return nil
    }
    static func getTrailer(videos: [VideosResult]? = nil) -> URL? {
        if let results = videos {
            for result in results {
                if result.name.contains("Official Trailer") && result.official {
                    return NetworkService.urlBuilder(video: result.key)
                }
            }
        }
        return nil
    }
}
