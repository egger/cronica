//
//  CronicaListsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/08/22.
//

import SwiftUI

struct CronicaListsView: View {
    static let tag: Screens? = .lists
    @State private var query = ""
    @State private var presentNewListAlert = false
    @State private var newListName = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomListItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CustomListItem>
    var body: some View {
        AdaptableNavigationView {
            VStack {
                List {
                    Section {
                        ForEach(DefaultListTypes.allCases) { list in
                            NavigationLink(value: list, label: {
                                VStack(alignment: .leading) {
                                    Text(list.title)
                                }
                            })
                        }
                    } header: {
                        Text("Default Lists")
                    }
                    
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                NavigationLink(value: item, label: {
                                    VStack(alignment: .leading) {
                                        Text(item.itemTitle)
                                            .lineLimit(1)
                                    }
                                })
                            }
                        } header: {
                            Text("Custom Lists")
                        }
                    }
                    
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Lists")
            .navigationDestination(for: DefaultListTypes.self) { item in
                if item == .people {
                    FavoritePeopleListView()
                } else {
                    DefaultListView(list: item)
                }
            }
            .navigationDestination(for: CustomListItem.self) { item in
                CustomListView(list: item)
            }
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button(action: {
                            presentNewListAlert.toggle()
                        }, label: {
                            Label("New List", systemImage: "plus.circle")
                        })
                        .alert("New List", isPresented: $presentNewListAlert, actions: {
                            TextField("New List", text: $newListName)
                            Button("Save") {
                                PersistenceController.shared.save(withTitle: newListName)
                                newListName = ""
                                presentNewListAlert.toggle()
                            }
                            Button("Cancel", role: .cancel) {
                                newListName = ""
                                presentNewListAlert.toggle()
                            }
                        }, message: {
                            Text("Enter a name for this list.")
                        })
                        EditButton()
                    }
                }
            }
            .dropDestination(for: ItemContent.self) { items, location  in
                let context = PersistenceController.shared
                for item in items {
                    context.save(item)
                }
                return true
            } isTargeted: { inDropArea in
                print(inDropArea)
            }
        }
    }
}
