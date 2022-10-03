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
    @State private var filteredItems = [WatchlistItem]()
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var showPicker = false
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
                        Section {
                            ForEach(filteredItems) { item in
                                NavigationLink(value: item) {
                                    WatchlistItemView(content: item)
                                }
                            }
                        } header: {
                            Text("Results from Watchlist")
                        }
                    } else {
                        List {
                            switch selectedOrder {
                            case .released:
                                WatchlistSectionView(items: items.filter { $0.isReleased },
                                                     title: "Released")
                            case .upcoming:
                                WatchlistSectionView(items: items.filter { $0.isUpcoming },
                                                     title: "Upcoming")
                            case .production:
                                WatchlistSectionView(items: items.filter { $0.isInProduction },
                                                     title: "In Production")
                            case .watched:
                                WatchlistSectionView(items: items.filter { $0.isWatched },
                                                     title: "Watched")
                            case .favorites:
                                WatchlistSectionView(items: items.filter { $0.isFavorite },
                                                     title: "Favorites")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .searchable(text: $query)
            .task(id: query) {
                do {
                    if query.isEmpty { return }
                    try await Task.sleep(nanoseconds: 300_000_000)
                    if !filteredItems.isEmpty { filteredItems.removeAll() }
                    filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                } catch {
                    if Task.isCancelled { return }
                    print(error.localizedDescription)
                }
            }
            .toolbar {
                ToolbarItem {
                    VStack {
                        Button(action: {
                            showPicker = true
                        }, label: {
                            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle.fill")
                        })
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .padding(.bottom)
                    }
                    
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
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    ScrollView(.vertical) {
                        ForEach(DefaultListTypes.allCases) { list in
                            Button(action: {
                                selectedOrder = list
                                showPicker = false
                            }, label: {
                                Text(list.title)
                            })
                        }
                    }
                    .navigationTitle("Sort List")
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
        } else {
            Text("No results")
        }
    }
}
