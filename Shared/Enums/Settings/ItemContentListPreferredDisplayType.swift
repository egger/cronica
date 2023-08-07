//
//  ItemContentListPreferredDisplayType.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/04/23.
//

import Foundation

enum ItemContentListPreferredDisplayType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case standard, card, poster
    
    var title: String {
        switch self {
        case .card: return NSLocalizedString("itemContentListPreferredDisplayTypeCard", comment: "")
        case .poster: return NSLocalizedString("itemContentListPreferredDisplayTypePoster", comment: "")
        default: return NSLocalizedString("itemContentListPreferredDisplayTypeStandard", comment: "")
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
