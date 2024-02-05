//
//  ItemContentListPreferredDisplayType.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 07/04/23.
//

import Foundation

enum ItemContentListPreferredDisplayType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case standard, card, poster
    
    var title: String {
        switch self {
        case .card: return NSLocalizedString("Card", comment: "")
        case .poster: return NSLocalizedString("Poster", comment: "")
        default: return NSLocalizedString("Standard", comment: "")
        }
    }
}

enum ShareLinkPreference: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case tmdb, cronica
    
    var title: String {
        switch self {
        case .tmdb:
            return "TMDB"
        case .cronica:
            return "Cronica"
        }
    }
}
