//
//  StoryApp.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI
import BackgroundTasks
import CoreData
import TelemetryClient

@main
struct StoryApp: App {
    @StateObject var dataController = WatchlistController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
    
    init() {
        let configuration = TelemetryManagerConfiguration(appID: "")
        TelemetryManager.initialize(with: configuration)
        registerRefreshBGTask()
    }
    
    private func registerRefreshBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "dev.alexandremadeira.Cronica.refresh",
                                        using: nil) { task in
            self.handleAppRefresh(task: task as! BGProcessingTask)
            TelemetryManager.send("registerRefreshBGTask")
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "dev.alexandremadeira.Cronica.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1440 * 60)
        request.requiresExternalPower = true
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
            TelemetryManager.send("scheduleAppRefreshBGTask")
        } catch {
            TelemetryManager.send("scheduleAppRefreshBGTaskError",
                                  with: ["Error:":"\(error.localizedDescription)"])
        }
    }
    
    private func handleAppRefresh(task: BGProcessingTask) {
        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let background = BackgroundManager()
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            background.handleAppRefreshContent()
            TelemetryManager.send("handleAppRefreshBGTask")
        }
        task.setTaskCompleted(success: true)
    }
}
