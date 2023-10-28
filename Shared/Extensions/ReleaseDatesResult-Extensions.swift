//
//  ReleaseDatesResult-Extensions.swift
//  Cronica
//
//  Created by Alexandre Madeira on 03/02/23.
//

import Foundation

extension [ReleaseDatesResult] {
    func toReleasedDateFormatted() -> Date? {
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
    
    private func getReleaseDates(for dates: [ReleaseDate]?) -> Date? {
        guard let dates else { return nil }
        for date in dates {
            if let type = date.type {
                
                if type == ReleaseDateType.theatrical.toInt {
                    return releaseToDate(for: date)
                }
                
                if type == ReleaseDateType.digital.toInt {
                    return releaseToDate(for: date)
                }
                
                if type == ReleaseDateType.tv.toInt {
                    return releaseToDate(for: date)
                }
                
                if type == ReleaseDateType.premiere.toInt {
                    return releaseToDate(for: date)
                }
            }
        }
        return nil
    }
    
    private func releaseToDate(for item: ReleaseDate) -> Date? {
        guard let release = item.releaseDate else { return nil }
        return String.releaseDateFormatter.date(from: release)
    }
}
