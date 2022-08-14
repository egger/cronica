//
//  ItemsWatchListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//

import SwiftUI

struct ItemsWatchListView: View {
    var items = [WatchlistItem]()
    var defaultList: DefaultListTypes?
    var customList: CustomListItem?
    var title: String
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @State private var query = ""
    @State private var renameListTitle = ""
    @State private var presentRenameListAlert = false
    private let persistence = PersistenceController.shared
    var body: some View {
        VStack {
            if items.isEmpty {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    if !filteredItems.isEmpty {
                        WatchListSection(items: filteredItems,
                                         title: "Search Items")
                    } else if !query.isEmpty && filteredItems.isEmpty {
                        Text("No results.")
                    } else {
                        WatchListSection(items: items, title: "\(items.count) titles")
                    }
                }
            }
        }
        .navigationTitle(title)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .toolbar {
            HStack {
                EditButton()
                if let customList {
                    Button(action: {
                        presentRenameListAlert = true
                    }, label: {
                        Label("Rename List", systemImage: "pencil.and.ellipsis.rectangle")
                            .labelStyle(.titleOnly)
                    })
                    .alert("Rename List", isPresented: $presentRenameListAlert, actions: {
                        TextField("Rename List", text: $renameListTitle)
                        Button("Save") {
                            persistence.renameList(customList, title: renameListTitle)
                            renameListTitle = ""
                            presentRenameListAlert.toggle()
                        }
                        Button("Cancel", role: .cancel) {
                            renameListTitle = ""
                            presentRenameListAlert.toggle()
                        }
                    }, message: {
                        Text("Enter a name for this list.")
                    })
                }
            }
        }
        .navigationDestination(for: WatchlistItem.self) { item in
            ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .dropDestination(for: ItemContent.self) { items, location  in
            let context = PersistenceController.shared
            for item in items {
                if let customList {
                    context.save(item, list: customList)
                } else {
                    context.save(item)
                }
            }
            return true
        } isTargeted: { inDropArea in
            print(inDropArea)
        }
    }
}
