//
//  CronicaWatchApp.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 02/08/22.
//

import SwiftUI

@main
struct CronicaWatch_Watch_AppApp: App {
    let persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            WatchlistView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
