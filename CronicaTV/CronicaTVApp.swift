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
    @StateObject var persistence = PersistenceController.shared
    @AppStorage("disableTelemetry") var disableTelemetry = false
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
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
