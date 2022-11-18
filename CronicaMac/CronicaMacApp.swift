//
//  CronicaMacApp.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import TelemetryClient

@main
struct CronicaMacApp: App {
    let persistence = PersistenceController.shared
    init() {
        CronicaTelemetry.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
        
        Settings {
            SettingsView()
        }
    }
}
