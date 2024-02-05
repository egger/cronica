//
//  SwipeGestureOptions.swift
//  Cronica
//
//  Created by Alexandre Madeira on 03/02/23.
//

import Foundation

enum SwipeGestureOptions: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case markWatch, markFavorite, markPin, markArchive, delete, share
    var localizableName: String {
        switch self {
        case .markWatch: NSLocalizedString("Watch", comment: "")
        case .markFavorite: NSLocalizedString("Favorite", comment: "")
        case .markPin: NSLocalizedString("Pin", comment: "")
        case .markArchive: NSLocalizedString("Archive", comment: "")
        case .delete: NSLocalizedString("Remove", comment: "")
        case .share: NSLocalizedString("Share", comment: "")
        }
    }
}


enum SecondaryButtonOptions: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case watched, favorite, archive, pin, review, lists
    
    var localizableTitle: String {
        switch self {
        case .watched: NSLocalizedString("Watch", comment: "")
        case .favorite: NSLocalizedString("Favorite", comment: "")
        case .archive: NSLocalizedString("Archive", comment: "")
        case .pin: NSLocalizedString("Pin", comment: "")
        case .review: NSLocalizedString("Review", comment: "")
        case .lists: NSLocalizedString("Lists", comment: "")
        }
    }
}
