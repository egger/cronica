//
//  DefaultListTypes.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//
import Foundation
import SwiftUI
import CoreData


enum DefaultListTypes: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case released, upcoming, production, favorites, watched, unwatched
    var title: String {
        switch self {
        case .released:
            return NSLocalizedString("Released", comment: "")
        case .upcoming:
            return NSLocalizedString("Upcoming", comment: "")
        case .production:
            return NSLocalizedString("In Production", comment: "")
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")
        case .watched:
            return NSLocalizedString("Watched", comment: "")
        case .unwatched:
            return NSLocalizedString("To Watch", comment: "")
        }
    }
}
