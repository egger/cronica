//
//  CronicaTelemetry.swift
//  Story
//
//  Created by Alexandre Madeira on 03/10/22.
//

import Foundation
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
    
    /// Send a signal using TelemetryDeck service.
    ///
    /// If it is running in Simulator or Debug, it will send a warning on logger.
    func handleMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator) || DEBUG
        logger.warning("\(message), for: \(id)")
#else
        if TelemetryManager.isInitialized {
            TelemetryManager.send("\(id)", with: ["Message":"\(message)"])
        }
#endif
    }
}
