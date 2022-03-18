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
    /// Builds a URL for a given image's path.
    /// - Parameters:
    ///   - size: Use ImageSize to select the returned image size.
    ///   - path: The path for the image.
    /// - Returns: Returns a URL with the image's size, and path.
    static func imageUrlBuilder(size: ImageSize, path: String?) -> URL? {
        let url = URL(string: "https://image.tmdb.org/\(size.rawValue)\(path ?? "")")
        let component = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        return component?.url
    }
}

enum ImageSize: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case small = "t/p/w154"
    case medium = "t/p/w500"
    case large = "t/p/w1066_and_h600_bestv2"
    case original = "t/p/original"
}
