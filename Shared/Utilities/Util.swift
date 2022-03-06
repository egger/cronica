//
//  Util.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import Foundation

class Util {
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
}
