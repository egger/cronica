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
}

extension Locale {
    func getUserLang() -> String {
        let locale = Locale.current
        guard let langCode = locale.language.languageCode?.identifier,
              let regionCode = locale.language.region?.identifier else {
            return "en-US"
        }
        return "\(langCode)-\(regionCode)"
    }
    
    func getUserRegion() -> String {
        guard let region = Locale.current.language.region?.identifier else {
            return "US"
        }
        return region
    }
}

extension Int {
    func convertToShortRuntime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        let value = formatter.string(from: TimeInterval(self) * 60)
        guard let value else {
            return ""
        }
        return value
    }
    
    func convertToLongRuntime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        let value = formatter.string(from: TimeInterval(self) * 60)
        guard let value else {
            return ""
        }
        return value
    }
}

extension String {
    func convertStringToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "y,MM,dd"
        return formatter.date(from: self)
    }
}

