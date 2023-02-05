//
//  DatesManager.swift
//  Story
//
//  Created by Alexandre Madeira on 05/02/23.
//

import Foundation

/// Migrate to extension based formatters and functions to get release dates and format the result.
class DatesManager {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y,MM,dd"
        return formatter
    }()
    static let dateString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    private static var releaseDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }
    static func getReleaseDateFormatted(results: [ReleaseDatesResult]) -> String? {
        for result in results {
            if result.iso31661 == Locale.userRegion {
                if result.releaseDates != nil {
                    for date in result.releaseDates! {
                        if date.type != nil && date.type == 3 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                        if date.type != nil && date.type == 4 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                        if date.type != nil && date.type == 6 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                    }
                }
            }
            if result.iso31661 == "US" {
                if let dates = result.releaseDates {
                    for date in dates {
                        if date.type != nil && date.type == 3 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                        if date.type != nil && date.type == 4 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                        if date.type != nil && date.type == 6 {
                            let release = releaseDateFormatter.date(from: date.releaseDate!)!
                            return dateString.string(from: release)
                        }
                    }
                }
            }
        }
        return nil
    }
}
