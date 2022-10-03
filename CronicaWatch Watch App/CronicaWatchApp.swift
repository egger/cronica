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
    @StateObject var persistence = PersistenceController.shared
    init() {
#if targetEnvironment(simulator)
#else
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey!)
        TelemetryManager.initialize(with: configuration)
#endif
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                WatchlistView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                SearchView()
            }
        }
    }
}
