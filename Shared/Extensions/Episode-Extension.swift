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
    var itemAbout: String {
        overview ?? "Not Available"
    }
    var itemNumber: String {
        return NSLocalizedString("Episode \(episodeNumber)", comment: "")
    }
    var itemImageMedium: URL? {
        return NetworkService.urlBuilder(size: .medium, path: stillPath)
    }
    var itemImageLarge: URL? {
        return NetworkService.urlBuilder(size: .large, path: stillPath)
    }
}
