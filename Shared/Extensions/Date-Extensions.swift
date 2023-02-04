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
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y,MM,dd"
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
        if let original = self, let new {
            if original != new { return true }
            return false
        }
        return false
    }
}
