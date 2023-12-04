//
//  WatchlistSearchScope.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 16/08/22.
//

import SwiftUI

enum WatchlistSearchScope: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case noScope, movies, shows
    var localizableTitle: String {
        switch self {
        case .noScope: return NSLocalizedString("All", comment: "")
        case .movies: return NSLocalizedString("Movies", comment: "")
        case .shows: return NSLocalizedString("Series", comment: "")
        }
    }
}
