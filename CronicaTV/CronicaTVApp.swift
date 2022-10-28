//
//  CronicaTVApp.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import TelemetryClient

@main
struct CronicaTVApp: App {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    init() {
#if targetEnvironment(simulator)
#else
        if !disableTelemetry {
            let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey!)
            TelemetryManager.initialize(with: configuration)
        }
#endif
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
