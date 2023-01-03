//
//  CronicaMacApp.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

@main
struct CronicaMacApp: App {
    var persistence = PersistenceController.shared
    @ObservedObject private var settings = SettingsStore.shared
    init() {
        CronicaTelemetry.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .tint(settings.appTheme.color)
                .fontDesign(.rounded)
                .appTheme()
        }
        
        Settings {
            SettingsView()
                .tint(settings.appTheme.color)
        }
    }
}
