//
//  Key.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//  swiftlint:disable line_length

import Foundation

struct Key {
    static let tmdbApi = ProcessInfo.processInfo.environment["tmdb_api"]
    static let telemetryClientKey = ProcessInfo.processInfo.environment["telemetry_client_key"]
}
