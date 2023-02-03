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
    
    func toFullDate() -> Date? {
        return Date.ISO8601Formatter.date(from: self)
    }
}

extension String? {
    static var mediumDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    func toFormattedStringDate() -> String? {
        if let value = self {
            let date = value.toFullDate()
            if let date {
                return Date.mediumDateFormatter.string(from: date)
            }
            return nil
        }
        return nil
    }
}
