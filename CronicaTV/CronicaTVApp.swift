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
    private let persistence = PersistenceController.shared
    init() {
        CronicaTelemetry.shared.setup()
        BackgroundManager.shared.registerRefreshBGTask()
        BackgroundManager.shared.registerAppMaintenanceBGTask()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
