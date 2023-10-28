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
        case .markWatch:
            return NSLocalizedString("swipeGestureWatch", comment: "")
        case .markFavorite:
            return NSLocalizedString("swipeGestureFavorite", comment: "")
        case .markPin:
            return NSLocalizedString("swipeGesturePin", comment: "")
        case .markArchive:
            return NSLocalizedString("swipeGestureArchive", comment: "")
        case .delete:
            return NSLocalizedString("Remove", comment: "")
        case .share:
            return NSLocalizedString("swipeGestureShare", comment: "")
        }
    }
}


enum SecondaryButtonOptions: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case watched, favorite, archive, pin, review, lists
    
    var localizableTitle: String {
        switch self {
        case .watched:
            return NSLocalizedString("Watch", comment: "")
        case .favorite:
            return NSLocalizedString("Favorite", comment: "")
        case .archive:
            return NSLocalizedString("Archive", comment: "")
        case .pin:
            return NSLocalizedString("Pin", comment: "")
        case .review:
            return NSLocalizedString("Review", comment: "")
        case .lists:
            return NSLocalizedString("Lists", comment: "")
        }
    }
}
