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
    #warning("You can also place your API Key here, the actual setup is just to make it work better with Xcode Cloud.")
    static var tmdbApi: String {
        let infoKey = "CRONICA_API_KEY_TMDB"
        guard let apiKey = Bundle.main.infoDictionary?[infoKey] as? String else { return String() }
        return apiKey
    }
    #warning("This is only for production code, you can remove it if you want to.")
    static var telemetryClientKey: String? {
        let infoKey = "CRONICA_API_KEY_TELEMETRYDECK"
        guard let apiKey = Bundle.main.infoDictionary?[infoKey] as? String else { return nil }
        if apiKey.isEmpty { return nil }
        return apiKey
    }
    static var authorizationHeader: String? {
        let infoKey = "CRONICA_API_KEY_TMDB_AuthorizationHeader"
        guard let apiKey = Bundle.main.infoDictionary?[infoKey] as? String else { return nil }
        if apiKey.isEmpty { return nil }
        return apiKey
    }
}
