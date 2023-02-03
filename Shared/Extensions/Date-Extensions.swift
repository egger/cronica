//
//  Date-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 04/11/22.
//

import Foundation

extension Date {
    func convertDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func compareDate(to new: Date?) -> Bool {
        guard let new else { return false }
        if self != new { return true }
        return false
    }
    
    static let ISO8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()
    
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Date? {
    /// This function calculates if the given date is less than two months away from today.
    func isLessThanTwoMonthsAway() -> Bool {
        if let date = self {
            let today = Date()
            let twoMonths = TimeInterval(60 * 24 * 60 * 60)
            if date < (today + twoMonths) { return true }
            return false
        }
        return false
    }
    
    func hasPassedOneWeek() -> Bool {
        if let date = self {
            let today = Date()
            let week = TimeInterval(7 * 24 * 60 * 60)
            if today > (date + week) { return true }
            return false
        }
        return false
    }
    
    func areDifferentDates(with new: Date?) -> Bool {
        if let original = self {
            if let new {
                if original != new { return true }
            }
            return false
        }
        return false
    }
}
