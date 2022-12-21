//
//  PreferredShareLink.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/12/22.
//

import Foundation

enum PreferredShareLink: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case tmdb = 0
    case imdb = 1
    var localizableNameTitle: String {
        switch self {
        case .tmdb: return NSLocalizedString("preferredShareLinkTMDB", comment: "")
        case .imdb: return NSLocalizedString("preferredShareLinkIMDB", comment: "")
        }
    }
}
