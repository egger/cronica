//
//  StoryApp.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

@main
struct StoryApp: App {
    @StateObject var dataController = DataController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
