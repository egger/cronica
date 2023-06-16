//
//  ItemSchedule.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

/// The value for the types of schedule supported by ItemContent and WatchlistItem.
///
/// This value is most used to quickly filter out WatchlistItem and handle better fetching in notifications.
enum ItemSchedule: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case soon, released, production, cancelled, unknown, renewed, ended
    var toInt: Int16 {
        switch self {
        case .soon: return 0
        case .released: return 1
        case .production: return 2
        case .cancelled: return 3
        case .unknown: return 4
        case .renewed: return 5
        case .ended: return 6
        }
    }
    var localizedTitle: String {
        switch self {
        case .soon:
            return NSLocalizedString("Coming Soon", comment: "")
        case .released:
            return NSLocalizedString("Released", comment: "")
        case .production:
            return NSLocalizedString("Production", comment: "")
        case .cancelled:
            return NSLocalizedString("Cancelled", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        case .renewed:
            return NSLocalizedString("Renewed Series", comment: "")
        case .ended:
            return NSLocalizedString("Ended Series", comment: "")
        }
    }
}
