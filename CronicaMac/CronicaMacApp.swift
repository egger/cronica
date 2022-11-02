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
    //let persistence = PersistenceController.shared
    init() {
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey!)
        TelemetryManager.initialize(with: configuration)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.environment(\.managedObjectContext,
                 //             PersistenceController.shared.container.viewContext)
        }
        
        Settings {
            SettingsView()
        }
    }
}
