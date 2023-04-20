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
    #warning("Please, check your TMDB API.")
    static let tmdbApi = ProcessInfo.processInfo.environment["tmdb_api"]
    #warning("TelemetryDeck service is used to track crashes, you can remove it. Read README file for more.")
    static let telemetryClientKey: String? = ProcessInfo.processInfo.environment["telemetry_client_key"]
}
