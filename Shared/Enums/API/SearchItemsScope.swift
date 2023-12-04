//
//  SearchItemsScope.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 16/08/22.
//

import SwiftUI

enum SearchItemsScope: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case noScope, movies, shows, people
    var localizableTitle: LocalizedStringKey {
        switch self {
        case .noScope: return "All"
        case .movies: return "Movies"
        case .shows: return "Series"
        case .people: return "People"
        }
    }
}
