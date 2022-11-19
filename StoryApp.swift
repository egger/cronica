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
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    private let backgroundProcessingIdentifier = "dev.alexandremadeira.cronica.backgroundProcessingTask"
    @Environment(\.scenePhase) private var scene
    @State private var widgetItem: ItemContent?
    @AppStorage("removedOldNotifications") private var removedOldNotifications = false
    init() {
        CronicaTelemetry.shared.setup()
        registerRefreshBGTask()
        registerAppMaintenanceBGTask()
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
                                Button("Done") {
                                    widgetItem = nil
                                }
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
                scheduleAppRefresh()
                scheduleAppMaintenance()
            }
        }
    }
    
    private func registerRefreshBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as? BGAppRefreshTask ?? nil)
        }
    }
    
    private func registerAppMaintenanceBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundProcessingIdentifier, using: nil) { task in
            self.handleAppMaintenance(task: task as? BGProcessingTask ?? nil)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 360 * 60) // Fetch no earlier than 6 hours from now
        try? BGTaskScheduler.shared.submit(request)
    }
    
    private func scheduleAppMaintenance() {
        let request = BGProcessingTaskRequest(identifier: backgroundProcessingIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        let oneWeek = TimeInterval(7 * 24 * 60 * 60)
        request.earliestBeginDate = Date(timeIntervalSinceNow: oneWeek)
        do {
            try BGTaskScheduler.shared.submit(request)
#if DEBUG
            print("Scheduled App Maintenance.")
#endif
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                            for: "scheduleAppMaintenance()")
        }
    }
    
    // Fetch the latest updates from api.
    private func handleAppRefresh(task: BGAppRefreshTask?) {
        if let task {
            scheduleAppRefresh()
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let background = BackgroundManager()
            task.expirationHandler = {
                // After all operations are cancelled, the completion block below is called to set the task to complete.
                queue.cancelAllOperations()
            }
            queue.addOperation {
                Task {
                    await background.handleAppRefreshContent()
                }
            }
            task.setTaskCompleted(success: true)
            CronicaTelemetry.shared.handleMessage("identifier: \(task.identifier)",
                                                            for: "handleAppRefreshBGTask")
        }
    }
    
    private func handleAppMaintenance(task: BGProcessingTask?) {
        guard let task else { return }
        scheduleAppMaintenance()
        let queue = OperationQueue()
        let background = BackgroundManager()
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            Task {
                await background.handleAppRefreshMaintenance(isAppMaintenance: true)
            }
        }
        task.setTaskCompleted(success: true)
        CronicaTelemetry.shared.handleMessage("identifier: \(task.identifier)",
                                                        for: "handleAppMaintenance")
    }
}
