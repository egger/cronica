//
//  Utilities.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import Foundation

class Utilities {
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
}
