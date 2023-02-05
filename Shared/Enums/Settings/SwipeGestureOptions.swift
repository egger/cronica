//
//  SwipeGestureOptions.swift
//  Story
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
            return NSLocalizedString("swipeGestureDelete", comment: "")
        case .share:
            return NSLocalizedString("swipeGestureShare", comment: "")
        }
    }
}
