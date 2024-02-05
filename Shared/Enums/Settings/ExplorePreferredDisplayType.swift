//
//  SectionDetailsPreferredStyle.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 07/04/23.
//

import Foundation

enum SectionDetailsPreferredStyle: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case list, card, poster
    
    var title: String {
        switch self {
        case .list: return NSLocalizedString("List", comment: "")
        case .card: return NSLocalizedString("Card", comment: "")
        case .poster: return NSLocalizedString("Poster", comment: "")
        }
    }
}
enum UpNextDetailsPreferredStyle: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case list, card
    
    var title: String {
        switch self {
        case .list: return NSLocalizedString("List", comment: "")
        case .card: return NSLocalizedString("Card", comment: "")
        }
    }
}
