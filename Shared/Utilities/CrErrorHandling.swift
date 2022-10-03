//
//  CrErrorHandling.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/10/22.
//

import Foundation
import os
import TelemetryClient

class CrErrorHandling {
    static let shared = CrErrorHandling()
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CrErrorHandling.self)
    )
    
    /// This function will send a message using TelemetryDeck Service if in production, else it'll send a log message.
    ///
    /// This function will respect user setting for sending the messages to the developer.
    func handleErrorMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator)
        CrErrorHandling.logger.error("\(message)")
#else
        TelemetryManager.send("\(id)", with: ["Error":"\(message)"])
#endif
    }
}
