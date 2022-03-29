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
    static func getReleaseDate(results: [ReleaseDatesResult]) -> Date? {
        for result in results {
            if result.iso31661 == Utilities.userRegion {
                if result.releaseDates != nil {
                    for date in result.releaseDates! {
                        if date.type != nil && date.type == 3 {
                            return Utilities.dateFormatter.date(from: date.releaseDate!)
                        }
                    }
                }
            }
        }
        return nil
    }
}
enum StyleType: Decodable {
    case poster
    case card
}
enum MediaType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case movie, person
    case tvShow = "tv"
    var title: String {
        switch self {
        case .movie:
            return NSLocalizedString("Movie", comment: "")
        case .tvShow:
            return NSLocalizedString("TV Show", comment: "")
        case .person:
            return NSLocalizedString("People", comment: "")
        }
    }
    var watchlistInt: Int {
        switch self {
        case .movie:
            return 0
        case .tvShow:
            return 1
        case .person:
            return 2
        }
    }
    var headline: String {
        switch self {
        case .movie:
            return "Movies"
        case .person:
            return "Person"
        case .tvShow:
            return "Shows"
        }
    }
    var append: String {
        switch self {
        case .movie:
            return "credits,recommendations,release_dates"
        case .person:
            return "combined_credits"
        case .tvShow:
            return "credits,recommendations"
        }
    }
}
enum ImageSize: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case small = "t/p/w154"
    case medium = "t/p/w500"
    case large = "t/p/w1066_and_h600_bestv2"
    case original = "t/p/original"
}
