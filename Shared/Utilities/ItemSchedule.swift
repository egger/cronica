//
//  ItemSchedule.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum ItemSchedule: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case soon, released, production, cancelled, unknown
    var scheduleNumber: Int16 {
        switch self {
        case .soon: return 0
        case .released: return 1
        case .production: return 2
        case .cancelled: return 3
        case .unknown: return 4
        }
    }
    var scheduleTitle: String {
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
        }
    }
}
