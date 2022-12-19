//
//  DoubleTapGesture.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import Foundation

/// Double tap values for the CoverImage gesture.
enum DoubleTapGesture: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case favorite = 0
    case watched = 1
    var title: String {
        switch self {
        case .favorite: return NSLocalizedString("Favorite", comment: "")
        case .watched: return NSLocalizedString("Watched", comment: "")
        }
    }
}
