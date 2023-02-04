//
//  String-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 03/02/23.
//

import Foundation

extension String {
    func convertStringToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "y,MM,dd"
        return formatter.date(from: self)
    }
}

extension String? {
    /// Format an string using an ISO8601 formatter.
    /// - Returns: If the string is valid, it will return a string with full date.
    func toFormattedStringDate() -> String? {
        let releaseDateFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withFullDate
            return formatter
        }()
        if let value = self {
            let date = releaseDateFormatter.date(from: value)
            if let date {
                return date.convertDateToString()
            }
        }
        return nil
    }
}
