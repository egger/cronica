//
//  Key.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//  swiftlint:disable line_length

import Foundation

/// The Keys used for the TMDb API and the TelemetryDeck service.
///
/// The values for each key is defined in an environment variable.
struct Key {
    static let tmdbApi = ProcessInfo.processInfo.environment["tmdb_api"]
    static let telemetryClientKey: String? = ProcessInfo.processInfo.environment["telemetry_client_key"]
}
