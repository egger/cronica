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
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CronicaTelemetry.self)
    )
    static let shared = CronicaTelemetry()
    
    private init() { }
    
    func setup() {
        guard let key = Key.telemetryClientKey else { return }
        let configuration = TelemetryManagerConfiguration(appID: key)
        TelemetryManager.initialize(with: configuration)
    }
    
    /// This function send a message using TelemetryDeck Service if in production, else it'll send a log message.
    ///
    /// This function will respect user setting for sending the messages to the developer.
    func handleMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator) || DEBUG
        logger.warning("\(message), for: \(id)")
#endif
        TelemetryManager.send("\(id)", with: ["Message":"\(message)"])
    }
}
