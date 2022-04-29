//
//  ContentSchedule.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum ContentSchedule: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case soon = "Coming Soon"
    case released = "Released"
    case production = "Production"
    case cancelled = "Cancelled"
    case unknown = "Unknown"
    var scheduleNumber: Int16 {
        switch self {
        case .soon: return 0
        case .released: return 1
        case .production: return 2
        case .cancelled: return 3
        case .unknown: return 4
        }
    }
}
