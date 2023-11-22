//
//  CronicaTelemetry.swift
//  Cronica
//
//  Created by Alexandre Madeira on 03/10/22.
//

import Foundation
import os
import TelemetryClient
#if os(macOS) || os(tvOS)
import Aptabase
#endif

struct CronicaTelemetry {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CronicaTelemetry.self)
    )
    static let shared = CronicaTelemetry()
    
    private init() { }
    
    func setup() {
#if !targetEnvironment(simulator) || !DEBUG
        guard let key = Key.telemetryClientKey else { return }
        let configuration = TelemetryManagerConfiguration(appID: key)
        TelemetryManager.initialize(with: configuration)
        guard let aptabaseKey = Key.aptabaseClientKey else { return }
        Aptabase.shared.initialize(appKey: aptabaseKey)
        Aptabase.shared.trackEvent("app_started")
#endif
    }
    
    /// Send a signal using TelemetryDeck service.
    ///
    /// If it is running in Simulator or Debug, it will send a warning on logger.
    func handleMessage(_ message: String, for id: String) {
#if targetEnvironment(simulator) || DEBUG
        logger.warning("\(message), for: \(id)")
#else
#if os(tvOS) || os(macOS)
        Aptabase.shared.trackEvent(id, with: ["Message": message])
#else
        if TelemetryManager.isInitialized {
            TelemetryManager.send("\(id)", with: ["Message":"\(message)"])
        }
#endif
#endif
    }
    
    var isTelemetryDeckInitialized: String {
        return TelemetryManager.isInitialized.description
    }
}
