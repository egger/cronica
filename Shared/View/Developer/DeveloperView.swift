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
    @State private var showAllitems = false
    private let background = BackgroundManager()
    private let service = NetworkService.shared
    var body: some View {
        Form {
            Section {
                TextField("Item ID", text: $itemIdField)
                    .keyboardType(.numberPad)
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
                                if let person {
                                    self.person = person
                                }
                            }
                        }
                        isFetching = false
                    }
                }, label: {
                    if isFetching {
                        ProgressView()
                    } else {
                        Text("Fetch")
                    }
                })
            } header: {
                Label("Fetch a single item.", systemImage: "hammer")
            }
            
            NavigationLink(destination: WelcomeView(), label: {
                Text("Show Onboarding")
            })
            
            Button(action: {
                background.handleAppRefreshMaintenance()
            }, label: {
                Text("Update items")
            })
            
            Button(action: {
                showAllitems.toggle()
            }, label: {
                Text("Show All Items")
            })
        }
        .navigationTitle("Developer tools")
        .sheet(item: $item) { item in
            NavigationStack {
                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
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
                        ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
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
                        ToolbarItem(placement: .navigationBarLeading) {
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
                        ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                    .navigationDestination(for: Person.self) { item in
                        PersonDetailsView(title: item.name, id: item.id)
                    }
            }
        }
        .sheet(isPresented: $showAllitems) {
            NavigationStack {
                ShowAllItemsView()
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                showAllitems.toggle()
                            }
                        }
                    }
            }
        }
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
            ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
    }
}
