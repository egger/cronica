//
//  DeveloperView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 29/08/22.
//
#if os(iOS) || os(macOS)
import SwiftUI
import CoreData

/// This view provides quick information and utilities to the developer.
struct DeveloperView: View {
    @State private var item: ItemContent?
    @State private var person: Person?
    @State private var itemIdField = ""
    @State private var itemMediaType: MediaType = .movie
    @State private var isFetching = false
    @State private var isFetchingAll = false
    @State private var userAccessId = String()
    @State private var userAccessToken = String()
    @State private var v3SessionID = String()
    private let persistence = PersistenceController.shared
    private let service = NetworkService.shared
    @State private var showOnboarding = false
    var body: some View {
        Form {
            Section("Network") {
                TextField("Item ID", text: $itemIdField)
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                Picker(selection: $itemMediaType) {
                    ForEach(MediaType.allCases) { media in
                        Text(media.title).tag(media)
                    }
                } label: {
                    Text("Select the Media Type")
                }
                Button {
                    Task {
                        if !itemIdField.isEmpty {
                            await MainActor.run {
                                withAnimation { isFetching = false }
                            }
                            if itemMediaType != .person {
                                let item = try? await service.fetchItem(id: Int(itemIdField)!, type: itemMediaType)
                                if let item {
                                    self.item = item
                                }
                            } else {
                                let person = try? await service.fetchPerson(id: Int(itemIdField)!)
                                guard let person else { return }
                                self.person = person
                            }
                        }
                        await MainActor.run {
                            withAnimation { isFetching = false }
                        }
                    }
                } label: {
                    if isFetching {
                        CenterHorizontalView {
                            ProgressView()
                        }
                    } else {
                        Text("Fetch")
                    }
                }
            }
            
            Section("Presentation") {
                Button("Show Onboarding") {
                    showOnboarding.toggle()
                }
                .sheet(isPresented: $showOnboarding) {
                    NavigationStack {
                        WelcomeView()
                            .interactiveDismissDisabled(false)
                    }
#if os(macOS)
                    .frame(width: 500, height: 700, alignment: .center)
#endif
                }
            }
            
            Section {
                Text("User Region: \(Locale.userRegion)")
                Text("User Lang: \(Locale.userLang)")
                Text("Is TelemetryDeck Initialized: \(CronicaTelemetry.shared.isTelemetryDeckInitialized)")
                Text("Last maintenance: \(BackgroundManager.shared.lastMaintenance?.convertDateToString() ?? "Nil")")
                Text("Last watching refresh: \(BackgroundManager.shared.lastWatchingRefresh?.convertDateToString() ?? "Nil")")
                Text("Last upcoming refresh: \(BackgroundManager.shared.lastUpcomingRefresh?.convertDateToString() ?? "Nil")")
            }
            
            Section("TMDB") {
                Text("User Access ID (TMDB): \(userAccessId)")
                    .textSelection(.enabled)
                Text("User Access Token (TMDB): \(userAccessToken)")
                    .textSelection(.enabled)
                Text("Session ID (TMDB): \(v3SessionID)")
                    .textSelection(.enabled)
            }
            .onAppear {
                let data = KeychainHelper.standard.read(service: "access-token", account: "cronicaTMDB-Sync")
                let IdData = KeychainHelper.standard.read(service: "access-id", account: "cronicaTMDB-Sync")
                let sessionID = KeychainHelper.standard.read(service: "session-id", account: "cronicaTMDB-Sync")
                guard let data else { return }
                let accessToken = String(data: data, encoding: .utf8)
                guard let accessToken else { return }
                userAccessToken = accessToken
                guard let IdData else { return }
                let accessId = String(data: IdData, encoding: .utf8)
                guard let accessId else { return }
                userAccessId = accessId
                guard let sessionID else { return }
                let idV3 = String(data: sessionID, encoding: .utf8)
                guard let idV3 else { return }
                v3SessionID = idV3
            }
            
        }
        .navigationTitle("Developer Options")
        .sheet(item: $item) { item in
            NavigationStack {
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia, handleToolbar: true)
                    .toolbar {
#if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            HStack {
                                Button("Done") {
                                    self.item = nil
                                }
                                Menu {
                                    Button {
                                        let watchlist = PersistenceController.shared.fetch(for: item.itemContentID)
                                        if let watchlist {
                                            CronicaTelemetry.shared.handleMessage("WatchlistItem: \(watchlist as Any)",
                                                                                  for: "DeveloperView.printObject")
                                        }
                                        CronicaTelemetry.shared.handleMessage("ItemContent: \(item as Any)",
                                                                              for: "DeveloperView.printObject")
                                    } label: {
                                        Label("Send Object to Developer", systemImage: "hammer.circle.fill")
                                    }
                                } label: {
                                    Image(systemName: "hammer")
                                }
                            }
                        }
#else
                        Button("Done") { self.item = nil }
#endif
                    }
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                    .navigationDestination(for: Person.self) { item in
                        PersonDetailsView(title: item.name, id: item.id)
                    }
            }
        }
        .sheet(item: $person) { item in
            NavigationStack {
                PersonDetailsView(title: item.name, id: item.id)
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                self.person = nil
                            }
                        }
                    }
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                    .navigationDestination(for: Person.self) { item in
                        PersonDetailsView(title: item.name, id: item.id)
                    }
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}
#endif
