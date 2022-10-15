//
//  TelemetryManager.swift
//  Story
//
//  Created by Alexandre Madeira on 03/10/22.
//

import SwiftUI
import os
import TelemetryClient

class TelemetryErrorManager {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    static let shared = TelemetryErrorManager()
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TelemetryErrorManager.self)
    )
    
    /// This function will send a message using TelemetryDeck Service if in production, else it'll send a log message.
    ///
    /// This function will respect user setting for sending the messages to the developer.
    func handleErrorMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator)
        logger.error("\(message), for: \(id)")
#else
        if disableTelemetry { return }
        TelemetryManager.send("\(id)", with: ["Message":"\(message)"])
#endif
    }
}
