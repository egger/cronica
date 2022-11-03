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
    let persistenceController = PersistenceController.shared
    init() {
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey!)
        TelemetryManager.initialize(with: configuration)
        TelemetryManager.updateDefaultUser(to: UUID().uuidString)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
        Settings {
            SettingsView()
        }
    }
}
