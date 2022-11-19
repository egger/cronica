//
//  DeveloperView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 29/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

/// This view should be used only on development phase.
/// Do not utilize this on the TestFlight/App Store version.
struct DeveloperView: View {
    @State private var item: ItemContent?
    @State private var person: Person?
    @State private var itemIdField: String = ""
    @State private var itemMediaType: MediaType = .movie
    @State private var isFetching = false
    @State private var isFetchingAll = false
    @State private var showAllItems = false
    @State private var showOnboardingMac = false
    @AppStorage("markEpisodeWatchedTap") private var episodeTap = false
    private let background = BackgroundManager()
    private let service = NetworkService.shared
    var body: some View {
        Form {
            Section {
                TextField("Item ID", text: $itemIdField)
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                Picker(selection: $itemMediaType, content: {
                    ForEach(MediaType.allCases) { media in
                        Text(media.title).tag(media)
                    }
                }, label: {
                    Text("Select the Media Type")
                })
                Button(action: {
                    Task {
                        if !itemIdField.isEmpty {
                            isFetching = true
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
                        isFetching = false
                    }
                }, label: {
                    if isFetching {
                        CenterHorizontalView {
                            ProgressView()
                        }
                    } else {
                        Text("Fetch")
                    }
                })
            } header: {
                Label("Fetch a single item.", systemImage: "hammer")
            }
            
            Section {
#if os(macOS)
                Button("Show Onboarding") {
                    showOnboardingMac.toggle()
                }
#else
                NavigationLink(
                    destination: WelcomeView(),
                    label: {
                        Text("Show Onboarding")
                    })
#endif
            } header: {
                Text("Presentation")
            }
            
            Section {
                Button(action: {
                    Task {
                        self.isFetchingAll = true
                        await background.handleAppRefreshMaintenance()
                        await background.handleAppRefreshContent()
                        self.isFetchingAll = false
                    }
                }, label: {
                    if isFetchingAll {
                        CenterHorizontalView {
                            ProgressView()
                        }
                    } else {
                        Text("Update Items")
                    }
                })
            } header: {
                Text("Sync")
            }
            Section {
                Button(action: {
                    showAllItems.toggle()
                }, label: {
                    Text("Show All Items")
                })
            } header: {
                Text("Items")
            }
            
        }
        .navigationTitle("Developer tools")
        .sheet(isPresented: $showOnboardingMac, content: {
            NavigationStack {
                WelcomeView()
                    .frame(width: 500, height: 700, alignment: .center)
            }
        })
        .sheet(item: $item) { item in
#if os(macOS)
            NavigationStack {
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                    .frame(width: 800, height: 500, alignment: .center)
                    .toolbar {
                        Button("Done") {
                            self.item = nil
                        }
                    }
            }
#else
            NavigationStack {
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            HStack {
                                Button("Done") {
                                    self.item = nil
                                }
                                Button(action: {
                                    let watchlist = try? PersistenceController.shared.fetch(for: Int64(itemIdField)!, media: itemMediaType)
                                    if let watchlist {
                                        print("Watchlist: \(watchlist.itemSchedule )")
                                    }
                                    print("Print object '\(item.itemTitle)': \(item as Any)")
                                }, label: {
                                    Label("Print object", systemImage: "hammer.circle.fill")
                                })
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
#endif
        }
        .sheet(item: $person) { item in
            NavigationStack {
                PersonDetailsView(title: item.name, id: item.id)
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                Button("Done") {
                                    self.person = nil
                                }
                                Button(action: {
                                    print("Print object '\(item.name)': \(item as Any)")
                                }, label: {
                                    Label("Print object", systemImage: "hammer.circle.fill")
                                })
                            }
                        }
                    }
                    .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
#else
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
                    }
                    .navigationDestination(for: Person.self) { item in
                        PersonDetailsView(title: item.name, id: item.id)
                    }
            }
        }
        .sheet(isPresented: $showAllItems) {
            NavigationStack {
                ShowAllItemsView()
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                showAllItems.toggle()
                            }
                        }
                    }
#if os(macOS)
                    .frame(width: 500, height: 500, alignment: .center)
#endif
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

private struct ShowAllItemsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    @State private var isSearching = false
    @State private var filteredItems = [WatchlistItem]()
    var body: some View {
        VStack {
            List {
                if isSearching {
                    ProgressView("Searching")
                } else if !filteredItems.isEmpty {
                    Section {
                        ForEach(filteredItems) { item in
                            WatchlistItemView(content: item)
                        }
                    } header: {
                        Text("Filtered items - \(filteredItems.count)")
                    }
                } else {
                    Section {
                        ForEach(items) { item in
                            WatchlistItemView(content: item)
                        }
                    } header: {
                        Text("All items - \(items.count)")
                    }
                }
                
            }
        }
        .searchable(text: $query)
        .task(id: query) {
            do {
                isSearching = true
                try await Task.sleep(nanoseconds: 300_000_000)
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                isSearching = false
            } catch {
                print(error.localizedDescription)
            }
        }
        .navigationTitle("All Items")
        .navigationDestination(for: WatchlistItem.self) { item in
#if os(macOS)
#else
            ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
#endif
        }
        .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
#else
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
    }
}
