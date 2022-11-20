//
//  StoryApp.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI
import BackgroundTasks
import TelemetryClient

@main
struct StoryApp: App {
    let persistence = PersistenceController.shared
    @Environment(\.scenePhase) private var scene
    @State private var widgetItem: ItemContent?
    @AppStorage("removedOldNotifications") private var removedOldNotifications = false
    init() {
        CronicaTelemetry.shared.setup()
        BackgroundManager.shared.registerRefreshBGTask()
        BackgroundManager.shared.registerAppMaintenanceBGTask()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .onOpenURL { url in
                    if widgetItem != nil { widgetItem = nil }
                    let typeInt = url.absoluteString.first!
                    let idString: String = url.absoluteString
                    let formattedIdString = String(idString.dropFirst())
                    let id = Int(formattedIdString)!
                    var type: MediaType
                    if typeInt == "0" {
                        type = .movie
                    } else {
                        type = .tvShow
                    }
                    Task {
                        widgetItem = try? await NetworkService.shared.fetchItem(id: id, type: type)
                    }
                }
                .sheet(item: $widgetItem) { item in
                    NavigationStack {
                        ItemContentDetails(title: item.itemTitle,
                                        id: item.id,
                                        type: item.itemContentMedia)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") { widgetItem = nil }
                            }
                        }
                        .navigationDestination(for: ItemContent.self) { item in
                            ItemContentDetails(title: item.itemTitle,
                                            id: item.id,
                                            type: item.itemContentMedia)
                        }
                        .navigationDestination(for: Person.self) { item in
                            PersonDetailsView(title: item.name, id: item.id)
                        }
                    }
                }
                .onAppear {
                    if !removedOldNotifications {
                        Task {
                            await NotificationManager.shared.clearOldNotificationId()
                        }
                    }
                }
        }
        .onChange(of: scene) { phase in
            if phase == .background {
                BackgroundManager.shared.registerRefreshBGTask()
                BackgroundManager.shared.registerAppMaintenanceBGTask()
            }
        }
    }
}
