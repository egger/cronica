//
//  Episode-Extension.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/04/22.
//

import Foundation

extension Episode {
    var itemTitle: String {
        name ?? "Not Available"
    }
    var itemOverview: String {
        overview ?? "Not Available"
    }
    var itemImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: stillPath)
    }
    var itemImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: stillPath)
    }
    var itemDate: String? {
        if let airDate {
            let date = Utilities.dateFormatter.date(from: airDate)
            if let date {
                return Utilities.dateString.string(from: date)
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
            return "Episode \(episodeNumber)"
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
        if !value.isEmpty {
            let unique: Set = Set(value)
            let result: [Person] = unique.sorted { $0.itemPopularity > $1.itemPopularity }
            return result
        }
        return value
    }
}
