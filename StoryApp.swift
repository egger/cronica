//
//  StoryApp.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//
import SwiftUI
import BackgroundTasks

@main
struct StoryApp: App {
    var persistence = PersistenceController.shared
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    private let backgroundProcessingIdentifier = "dev.alexandremadeira.cronica.backgroundProcessingTask"
    @Environment(\.scenePhase) private var scene
    @State private var widgetItem: ItemContent?
    @ObservedObject private var settings = SettingsStore.shared
    init() {
        CronicaTelemetry.shared.setup()
        registerRefreshBGTask()
        registerAppMaintenanceBGTask()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .appTint()
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
                        do {
                            widgetItem = try await NetworkService.shared.fetchItem(id: id, type: type)
                        } catch {
                            let message = "Item ID: \(id). Item Type: \(type.rawValue)."
                            CronicaTelemetry.shared.handleMessage("\(message)\(error.localizedDescription)",
                                                                  for: "CronicaWidgetLoadItem")
                        }
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
                        .navigationDestination(for: [String:[ItemContent]].self) { item in
                            let keys = item.map { (key, value) in key }
                            let value = item.map { (key, value) in value }
                            ItemContentCollectionDetails(title: keys[0], items: value[0])
                        }
                        .navigationDestination(for: ProductionCompany.self) { item in
                            CompanyDetails(company: item)
                        }
                    }
                    .appTheme()
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
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            let message = """
Can't schedule 'scheduleAppRefresh', error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppRefresh()")
        }
    }
    
    private func scheduleAppMaintenance() {
        let lastMaintenanceDate = BackgroundManager.shared.lastMaintenance ?? .distantPast
        let now = Date()
        let twoDays = TimeInterval(2 * 24 * 60 * 60)
        
        // Maintenance the database at most two days per week.
        guard now > (lastMaintenanceDate + twoDays) else { return }
        let request = BGProcessingTaskRequest(identifier: backgroundProcessingIdentifier)
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: twoDays)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            let message = """
Can't schedule 'scheduleAppMaintenance', error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppMaintenance()")
        }
    }
    
    // Fetch the latest updates from api.
    private func handleAppRefresh(task: BGAppRefreshTask?) {
        if let task {
            scheduleAppRefresh()
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            task.expirationHandler = {
                // After all operations are cancelled, the completion block below is called to set the task to complete.
                queue.cancelAllOperations()
            }
            queue.addOperation {
                Task {
                    await BackgroundManager.shared.handleAppRefreshContent()
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
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            Task {
                await BackgroundManager.shared.handleAppRefreshMaintenance(isAppMaintenance: true)
            }
        }
        task.setTaskCompleted(success: true)
        BackgroundManager.shared.lastMaintenance = Date()
        CronicaTelemetry.shared.handleMessage("identifier: \(task.identifier)",
                                                        for: "handleAppMaintenance")
    }
}
