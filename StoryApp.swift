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
    @StateObject var dataController = DataController.shared
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    @Environment(\.scenePhase) private var scenePhase
    init() {
        let configuration = TelemetryManagerConfiguration(appID: "")
        TelemetryManager.initialize(with: configuration)
        registerRefreshBGTask()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .background:
                        scheduleAppRefresh()
                    default:
                        print("Phase: \(phase).")
                    }
                }
        }
    }
    
    //MARK: Background task
    private func registerRefreshBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 480 * 60) // Fetch no earlier than 8 hours from now
        try? BGTaskScheduler.shared.submit(request)
    }
    
    // Fetch the latest updates from api.
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let background = BackgroundManager()
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }
        queue.addOperation {
            background.handleAppRefreshContent()
        }
        task.setTaskCompleted(success: true)
        TelemetryManager.send("handleAppRefreshBGTask", with: ["identifier":"\(task.identifier)"])
    }
}
