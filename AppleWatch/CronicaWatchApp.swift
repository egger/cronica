//
//  CronicaWatchApp.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 02/08/22.
//

import SwiftUI
import TelemetryClient

@main
struct CronicaWatchApp: App {
    var persistence = PersistenceController.shared
    init() {
        CronicaTelemetry.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            WatchlistView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
