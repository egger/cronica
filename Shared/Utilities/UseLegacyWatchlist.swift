//
//  UseLegacyWatchlist.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//

import Foundation

enum UseLegacyWatchlist: Int {
    case legacy = 0
    case new = 1
    var title: String {
        switch self {
        case .legacy: return NSLocalizedString("Legacy", comment: "")
        case .new: return NSLocalizedString("New", comment: "")
        }
    }
}
