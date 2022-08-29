//
//  DeveloperView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 29/08/22.
//

import SwiftUI

/// This view should be used only on development phase.
/// Do not utilize this on the TestFlight/App Store version.
struct DeveloperView: View {
    static let tag: Screens? = .developer
    @State private var item: ItemContent?
    @State private var items = [ItemContent]()
    @State private var person: Person?
    @State private var itemIdField: String = ""
    @State private var itemMediaType: MediaType = .movie
    @State private var isFetching = false
    @State private var isFetchingNotification = false
    @State private var showItems = false
    private let service = NetworkService.shared
    var body: some View {
        AdaptableNavigationView {
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
                Section {
                    Button(action: {
                        Task {
                            isFetchingNotification = true
                            items = await NotificationManager.shared.fetchUpcomingNotifications() ?? []
                            showItems = true
                            isFetchingNotification = false
                        }
                    }, label: {
                        if isFetchingNotification {
                            ProgressView()
                        } else {
                            Text("Fetch Notifications")
                        }
                    })
                } header: {
                    Label("Notifications", systemImage: "bell")
                }
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
            .sheet(isPresented: $showItems) {
                NavigationStack {
                    VStack {
                        if items.isEmpty {
                            Text("Empty list")
                        } else {
                            List {
                                ForEach(items) { item in
                                    NavigationLink(value: item) {
                                        Text(item.itemTitle)
                                    }
                                }
                            }
                        }
                    }
                    .task {
                        
                    }
                    .toolbar {
                        Button("Done") {
                            showItems = false
                            items = []
                        }
                    }
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                    .navigationDestination(for: Person.self) { item in
                        PersonDetailsView(title: item.name, id: item.id)
                    }
                    .navigationBarTitle("Pending Notifications Request")
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
