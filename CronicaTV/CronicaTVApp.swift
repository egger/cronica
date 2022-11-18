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
    let persistence = PersistenceController.shared
    init() {
        CronicaTelemetry.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
