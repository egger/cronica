//
//  DoubleTapGesture.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import Foundation

enum DoubleTapGesture: Int {
    case favorite = 0
    case watched = 1
    var title: String {
        switch self {
        case .favorite:
            return "Favorite"
        case .watched:
            return "Watched"
        }
    }
}
