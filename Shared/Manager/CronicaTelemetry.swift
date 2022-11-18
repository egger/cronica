//
//  CronicaTelemetry.swift
//  Story
//
//  Created by Alexandre Madeira on 03/10/22.
//

import SwiftUI
import os
import TelemetryClient

struct CronicaTelemetry {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CronicaTelemetry.self)
    )
    static let shared = CronicaTelemetry()
    
    func setup() {
#if targetEnvironment(simulator)
#else
        if disableTelemetry { return }
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey!)
        TelemetryManager.initialize(with: configuration)
#if os(macOS)
        TelemetryManager.updateDefaultUser(to: UUID().uuidString)
#endif
#endif
    }
    
    /// This function send a message using TelemetryDeck Service if in production, else it'll send a log message.
    ///
    /// This function will respect user setting for sending the messages to the developer.
    func handleMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator) || DEBUG
        logger.error("\(message), for: \(id)")
#else
        if disableTelemetry { return }
        TelemetryManager.send("\(id)", with: ["Message":"\(message)"])
#endif
    }
}
