//
//  CronicaApp.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//
import SwiftUI
import BackgroundTasks
import NotificationCenter

@main
struct CronicaApp: App {
    var persistence = PersistenceController.shared
    private let backgroundIdentifier = "dev.alexandremadeira.cronica.refreshContent"
    private let backgroundProcessingIdentifier = "dev.alexandremadeira.cronica.backgroundProcessingTask"
    @Environment(\.scenePhase) private var scene
    @State private var widgetItem: ItemContent?
    @State private var notificationItem: ItemContent?
    @ObservedObject private var settings = SettingsStore.shared
    @ObservedObject private var notificationDelegate = NotificationDelegate()
    init() {
        CronicaTelemetry.shared.setup()
        registerRefreshBGTask()
        registerAppMaintenanceBGTask()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { item in
                    fetchNotificationItem()
                }
                .onOpenURL { url in
                    if widgetItem != nil { widgetItem = nil }
                    if notificationItem != nil { notificationItem = nil }
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
#if os(iOS)
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
                        .navigationDestination(for: Person.self) { person in
                            PersonDetailsView(title: person.name, id: person.id)
                        }
                        .navigationDestination(for: [String:[ItemContent]].self) { item in
                            let keys = item.map { (key, _) in key }
                            let value = item.map { (_, value) in value }
                            ItemContentCollectionDetails(title: keys[0], items: value[0])
                        }
                        .navigationDestination(for: [Person].self) { items in
                            DetailedPeopleList(items: items)
                        }
                        .navigationDestination(for: ProductionCompany.self) { item in
                            CompanyDetails(company: item)
                        }
                        .navigationDestination(for: [ProductionCompany].self) { item in
                            CompaniesListView(companies: item)
                        }
#elseif os(macOS)
                        ItemContentDetailsView(id: item.id,
                                               title: item.itemTitle,
                                               type: item.itemContentMedia,
                                               handleToolbarOnPopup: true)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    widgetItem = nil
                                }
                            }
                        }
#endif
                    }
#if os(macOS)
                    .presentationDetents([.large])
                    .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#elseif os(iOS)
                    .appTheme()
                    .appTint()
#endif
                }
                .sheet(item: $notificationItem) { item in
                    NavigationStack {
#if os(iOS)
                        ItemContentDetails(title: item.itemTitle,
                                           id: item.id,
                                           type: item.itemContentMedia)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    notificationItem = nil
                                }
                            }
                        }
                        .navigationDestination(for: ItemContent.self) { item in
                            ItemContentDetails(title: item.itemTitle,
                                               id: item.id,
                                               type: item.itemContentMedia)
                        }
                        .navigationDestination(for: Person.self) { person in
                            PersonDetailsView(title: person.name, id: person.id)
                        }
                        .navigationDestination(for: [String:[ItemContent]].self) { item in
                            let keys = item.map { (key, _) in key }
                            let value = item.map { (_, value) in value }
                            ItemContentCollectionDetails(title: keys[0], items: value[0])
                        }
                        .navigationDestination(for: [Person].self) { items in
                            DetailedPeopleList(items: items)
                        }
                        .navigationDestination(for: ProductionCompany.self) { item in
                            CompanyDetails(company: item)
                        }
                        .navigationDestination(for: [ProductionCompany].self) { item in
                            CompaniesListView(companies: item)
                        }
#elseif os(macOS)
                        ItemContentDetailsView(id: item.id,
                                               title: item.itemTitle,
                                               type: item.itemContentMedia,
                                               handleToolbarOnPopup: true)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    notificationItem = nil
                                }
                            }
                        }
#endif
                    }
#if os(macOS)
                    .presentationDetents([.large])
                    .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#elseif os(iOS)
                    .appTheme()
                    .appTint()
#endif
                }
        }
        .onChange(of: scene) { phase in
            if phase == .background {
                scheduleAppRefresh()
                scheduleAppMaintenance()
            }
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
    
    private func fetchNotificationItem() {
        guard let id = notificationDelegate.notificationID else { return }
        if notificationItem != nil { notificationItem = nil }
        if widgetItem != nil { widgetItem = nil }
        let typeInt = id.first!
        let idString: String = id
        let formattedIdString = String(idString.dropFirst())
        let contentId = Int(formattedIdString)!
        var type: MediaType
        if typeInt == "0" {
            type = .movie
        } else {
            type = .tvShow
        }
        Task {
            do {
                notificationItem = try await NetworkService.shared.fetchItem(id: contentId, type: type)
            } catch {
                let message = "Item ID: \(contentId). Item Type: \(type.rawValue)."
                CronicaTelemetry.shared.handleMessage("\(message)\(error.localizedDescription)",
                                                      for: "CronicaApp.fetchNotificationItem.failed")
            }
        }
    }
    
    private func registerRefreshBGTask() {
#if os(iOS)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as? BGAppRefreshTask ?? nil)
        }
#endif
    }
    
    private func registerAppMaintenanceBGTask() {
#if os(iOS)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundProcessingIdentifier, using: nil) { task in
            self.handleAppMaintenance(task: task as? BGProcessingTask ?? nil)
        }
#endif
    }
    
    private func scheduleAppRefresh() {
#if os(iOS)
        let request = BGAppRefreshTaskRequest(identifier: backgroundIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 360 * 60) // Fetch no earlier than 6 hours from now
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            let message = """
Can't schedule 'scheduleAppRefresh', error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppRefresh.error")
        }
#endif
    }
    
    private func scheduleAppMaintenance() {
#if os(iOS)
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
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppMaintenance.error")
        }
#endif
    }
    
#if os(iOS)
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
                                                  for: "handleAppRefreshBGTask.success")
        }
    }
#endif
    
#if os(iOS)
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
                                              for: "handleAppMaintenance.success")
    }
#endif
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    
    var notificationID: String?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Get the ID of the notification from its userInfo dictionary
        notificationID = response.notification.request.content.userInfo["notificationID"] as? String
        
        completionHandler()
    }
}
