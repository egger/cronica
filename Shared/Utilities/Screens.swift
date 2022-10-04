//
//  Screens.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum Screens: String, Identifiable {
    var id: String { rawValue }
    case home, discover, watchlist, search
}
