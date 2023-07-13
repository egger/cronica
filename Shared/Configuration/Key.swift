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
    #warning("You can place your API Key here.")
    static let tmdbApi: String = ""
    static let telemetryClientKey: String? = ""
    static let authorizationHeader: String?  = ""
}
