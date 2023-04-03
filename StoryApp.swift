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
    @State private var showWhatsNew = false
    @ObservedObject private var settings = SettingsStore.shared
    init() {
        CronicaTelemetry.shared.setup()
        registerRefreshBGTask()
        registerAppMaintenanceBGTask()
        //checkVersion()
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
                            #if os(macOS)
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    widgetItem = nil
                                }
                            }
                            #else
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    widgetItem = nil
                                }
                            }
                            #endif
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
                        EmptyView()
                        #endif
                    }
                    .appTheme()
                    .appTint()
                }
                .sheet(isPresented: $showWhatsNew) {
#if os(iOS) || os(macOS)
                    ChangelogView(showChangelog: $showWhatsNew)
                        .onDisappear {
                            showWhatsNew = false
                        }
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
    
    private func checkVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastSeenVersion = UserDefaults.standard.string(forKey: UserDefaults.lastSeenAppVersionKey)
        if SettingsStore.shared.displayOnboard {
            return
        } else {
            if currentVersion != lastSeenVersion {
                showWhatsNew.toggle()
                UserDefaults.standard.set(currentVersion, forKey: UserDefaults.lastSeenAppVersionKey)
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
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppRefresh()")
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
            CronicaTelemetry.shared.handleMessage(message, for: "scheduleAppMaintenance()")
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
                                                            for: "handleAppRefreshBGTask")
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
                                                        for: "handleAppMaintenance")
    }
    #endif
}
