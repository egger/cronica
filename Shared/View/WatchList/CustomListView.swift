//
//  CustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/08/22.
//

import SwiftUI

struct CustomListView: View {
    let list: CustomListItem
    private let persistence = PersistenceController.shared
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    @State private var renameListTitle = ""
    @State private var presentRenameListAlert = false
    var body: some View {
        VStack {
            if !items.isEmpty {
                List {
                    ForEach(items.filter { $0.list == list }) { item in
                        ItemView(content: item)
                    }
                }
            } else {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(list.itemTitle)
        .navigationDestination(for: WatchlistItem.self) { item in
            ItemContentView(title: item.itemTitle, id: Int(item.id), type: item.itemMedia)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    EditButton()
                    Button(action: {
                        presentRenameListAlert = true
                    }, label: {
                        Label("Rename List", systemImage: "pencil.and.ellipsis.rectangle")
                    })
                    .alert("Reame List", isPresented: $presentRenameListAlert, actions: {
                        TextField("Rename List", text: $renameListTitle)
                        Button("Save") {
                            persistence.renameList(list, title: renameListTitle)
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
        .dropDestination(for: ItemContent.self) { items, location  in
            let context = PersistenceController.shared
            for item in items {
                context.save(item, list: list)
            }
            return true
        } isTargeted: { inDropArea in
            print(inDropArea)
        }
    }
}
