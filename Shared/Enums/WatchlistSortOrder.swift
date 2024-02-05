//
//  WatchlistSortOrder.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/02/24.
//

import Foundation

enum WatchlistSortOrder: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case titleAsc, titleDesc, dateAsc, dateDesc, ratingAsc, ratingDesc
    
    var localizableName: String {
        switch self {
        case .titleAsc: NSLocalizedString("Title (Asc)", comment: "")
        case .titleDesc: NSLocalizedString("Title (Desc)", comment: "")
        case .dateAsc: NSLocalizedString("Date (Asc)", comment: "")
        case .dateDesc: NSLocalizedString("Date (Desc)", comment: "")
        case .ratingAsc: NSLocalizedString("Rating (Asc)", comment: "")
        case .ratingDesc: NSLocalizedString("Rating (Desc)", comment: "")
        }
    }
}
