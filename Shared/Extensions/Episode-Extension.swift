//
//  Episode-Extension.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/04/22.
//

import Foundation
#warning("episode date is one day ahead, check the last of us")

extension Episode {
    var itemTitle: String {
        name ?? "Not Available"
    }
    var itemOverview: String {
        if let overview {
            if !overview.isEmpty {
                return overview
            }
        }
        return NSLocalizedString("Not Available", comment: "")
    }
    var itemImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: stillPath)
    }
    var itemImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: stillPath)
    }
    var itemImageOriginal: URL? {
        return NetworkService.urlBuilder(size: .original, path: stillPath)
    }
    var itemDate: String? {
        if let airDate {
            let date = airDate.convertStringToDate()
            //let date = Utilities.dateFormatter.date(from: airDate)
            if let date {
                return date.convertDateToString()
                //return Utilities.dateString.string(from: date)
            }
        }
        return nil
    }
    var itemInfo: String? {
        if let itemDate {
            if let episodeNumber {
                return "Episode \(episodeNumber) • \(itemDate)"
            }
        }
        if let episodeNumber {
            return NSLocalizedString("Episode \(episodeNumber)", comment: "")
        }
        return nil
    }
    var itemCast: [Person] {
        var value = [Person]()
        if let crew {
            value.append(contentsOf: crew)
        }
        if let guestStars {
            value.append(contentsOf: guestStars)
        }
        return value
    }
}
