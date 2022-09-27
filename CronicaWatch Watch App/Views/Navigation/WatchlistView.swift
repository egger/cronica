//
//  WatchlistView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @State private var selectedOrder: DefaultListTypes = .released
    var body: some View {
        NavigationStack {
            VStack {
                if items.isEmpty {
                    Text("Your list is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    if !filteredItems.isEmpty {
                        List(filteredItems) { item in
                            NavigationLink(value: item) {
                                WatchlistItemView(content: item)
                            }
                        }
                    } else if !query.isEmpty && filteredItems.isEmpty {
                        Text("No results")
                    } else {
                        List {
                            WatchlistSectionView(items: items.filter { $0.isReleased },
                                                 title: "Released")
                            WatchlistSectionView(items: items.filter { $0.isUpcoming },
                                                 title: "Upcoming")
                            WatchlistSectionView(items: items.filter { $0.isInProduction },
                                                 title: "In Production")
                            WatchlistSectionView(items: items.filter { $0.isWatched },
                                                 title: "Watched")
                            
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .searchable(text: $query, prompt: "Search watchlist")
            .toolbar {
                ToolbarItem {
//                    Menu(content: {
//                        Picker("Sort Watchlist",
//                               selection: $selectedOrder) {
//                            ForEach(DefaultListTypes.allCases) { list in
//                                Text(list.title).tag(list)
//                            }
//                        }
//                    }, label: {
//                        Text("Hey")
//                    })
                    
                    NavigationLink(value: Screens.search) {
                        Label("Search TMDb", systemImage: "globe")
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .padding(.bottom)
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
            }
            .navigationDestination(for: Screens.self) { screen in
                if screen == .search {
                    SearchView()
                }
            }
            
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

private struct WatchlistSectionView: View {
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    WatchlistItemView(content: item)
                }
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
            .padding(.bottom)
        }
    }
}
