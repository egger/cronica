//
//  Season-Extension.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/04/22.
//

import Foundation

extension Season {
    var itemTitle: String {
        name ?? NSLocalizedString("Not Available",
                                  comment: "")
    }
    var itemAbout: String {
        overview ?? NSLocalizedString("Not Available",
                                      comment: "")
    }
    var posterImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: posterPath)
    }
}
