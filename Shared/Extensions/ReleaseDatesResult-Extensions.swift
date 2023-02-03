//
//  ReleaseDatesResult-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 03/02/23.
//

import Foundation

extension [ReleaseDatesResult] {
    func toReleasedDateFormatted() -> String? {
        for item in self {
            if let iso = item.iso31661 {
                if iso.lowercased() == Locale.userRegion.lowercased() {
                    return getReleaseDates(for: item.releaseDates)
                }
                // If the user country is not found in the ISO, then US is used.
                if iso.lowercased() == "us" {
                    return getReleaseDates(for: item.releaseDates)
                }
            }
        }
        return nil
    }
    
    private func getReleaseDates(for dates: [ReleaseDate]?) -> String? {
        if let dates {
            for date in dates {
                // All types can be check out in https://developers.themoviedb.org/3/movies/get-movie-release-dates
                if let type = date.type {
                    // Type 3 is Theatrical release
                    if type == 3 {
                        return date.releaseDate.toFormattedStringDate()
                    }
                    // Type 4 is Digital
                    if type == 4 {
                        return date.releaseDate.toFormattedStringDate()
                    }
                    // Type 6 is TV
                    if type == 6 {
                        return date.releaseDate.toFormattedStringDate()
                    }
                    // Type 1 is Premiere
                    if type == 1 {
                        return date.releaseDate.toFormattedStringDate()
                    }
                }
            }
        }
        return nil
    }
}
