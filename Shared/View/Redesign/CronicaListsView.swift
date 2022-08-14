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
    @State private var listTitle = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomListItem.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomListItem>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    private let persistence = PersistenceController.shared
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
                        NavigationLink("Favorite People", destination: FavoritePeopleListView())
                    }
                    
                    if !lists.isEmpty {
                        Section {
                            ForEach(lists) { item in
                                NavigationLink(value: item, label: {
                                    VStack(alignment: .leading) {
                                        Text(item.itemTitle)
                                            .lineLimit(1)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive, action: {
                                            deleteItem(item)
                                        }, label: {
                                            Label("Delete List", systemImage: "trash")
                                        })
                                    }
                                })
                            }
                            .onDelete(perform: delete)
                        } header: {
                            Text("Custom Lists")
                        }
                    }
                    
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Lists")
            .searchable(text: $query, prompt: "Search Watchlist")
            .navigationDestination(for: DefaultListTypes.self) { item in
                switch item {
                case .released: ItemsWatchListView(items: items.filter { $0.isReleased },
                                                defaultList: item,
                                                title: item.title)
                case .upcoming: ItemsWatchListView(items: items.filter { $0.isUpcoming },
                                                defaultList: item,
                                                title: item.title)
                case .production: ItemsWatchListView(items: items.filter { $0.isInProduction },
                                                  defaultList: item,
                                                  title: item.title)
                case .favorites: ItemsWatchListView(items: items.filter { $0.isFavorite },
                                                 defaultList: item,
                                                 title: item.title)
                case .watched: ItemsWatchListView(items: items.filter { $0.isWatched },
                                               defaultList: item,
                                               title: item.title)
                case .unwatched: ItemsWatchListView(items: items.filter { !$0.isWatched },
                                                 defaultList: item,
                                                 title: item.title)
                }
            }
            .navigationDestination(for: CustomListItem.self) { item in
                ItemsWatchListView(items: items.filter { $0.list == item },
                                                 customList: item,
                                                 title: item.itemTitle)
            }
            .toolbar {
#if targetEnvironment(simulator)
                ToolbarItem {
                    HStack {
                        Button(action: {
                            presentNewListAlert.toggle()
                        }, label: {
                            Label("New List", systemImage: "plus.circle")
                        })
                        .alert("New List", isPresented: $presentNewListAlert, actions: {
                            TextField("New List", text: $listTitle)
                            Button("Save") {
                                if !listTitle.isEmpty {
                                    PersistenceController.shared.save(withTitle: listTitle)
                                    listTitle = ""
                                    presentNewListAlert.toggle()
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                listTitle = ""
                                presentNewListAlert.toggle()
                            }
                        }, message: {
                            Text("Enter a name for this list.")
                        })
                        if !lists.isEmpty {
                            EditButton()
                        }
                    }
                }
#endif
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
    
    func deleteItem(_ item: CustomListItem) {
        withAnimation {
            persistence.delete(item)
        }
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            offsets.map { items[$0] }.forEach(persistence.delete)
        }
    }
}
