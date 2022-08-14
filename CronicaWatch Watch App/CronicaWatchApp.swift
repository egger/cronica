//
//  CronicaWatchApp.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 02/08/22.
//

import SwiftUI
import TelemetryClient

@main
struct CronicaWatch_Watch_AppApp: App {
    let persistence = PersistenceController.shared
    init() {
#if targetEnvironment(simulator)
#else
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey)
        TelemetryManager.initialize(with: configuration)
#endif
    }
    var body: some Scene {
        WindowGroup {
            WatchlistView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
