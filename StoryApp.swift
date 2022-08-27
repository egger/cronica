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
    @Environment(\.scenePhase) private var scene
    @State private var widgetItem: ItemContent?
    init() {
#if targetEnvironment(simulator)
#else
        let configuration = TelemetryManagerConfiguration(appID: Key.telemetryClientKey)
        TelemetryManager.initialize(with: configuration)
#endif
        registerRefreshBGTask()
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
                        widgetItem = try? await NetworkService.shared.fetchContent(id: id, type: type)
                    }
                }
                .sheet(item: $widgetItem) { item in
                    NavigationStack {
                        ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") {
                                        widgetItem = nil
                                    }
                                }
                            }
                    }
                }
        }
        .onChange(of: scene) { phase in
            if phase == .background {
                scheduleAppRefresh()
            }
        }
    }
    
    private func registerRefreshBGTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as? BGAppRefreshTask ?? nil)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 360 * 60) // Fetch no earlier than 6 hours from now
        try? BGTaskScheduler.shared.submit(request)
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
                background.handleAppRefreshContent()
            }
            task.setTaskCompleted(success: true)
#if targetEnvironment(simulator)
#else
            TelemetryManager.send("handleAppRefreshBGTask", with: ["identifier":"\(task.identifier)"])
#endif
        }
    }
}
