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
    @StateObject private var searchVM = SearchViewModel()
    @State private var isInWatchlist = false
    var body: some View {
        NavigationStack {
            VStack {
                if !query.isEmpty {
                    List {
                        Section {
                            if !filteredItems.isEmpty {
                                ForEach(filteredItems) { item in
                                    NavigationLink(value: item) {
                                        WatchlistItemView(content: item)
                                    }
                                }
                            } else {
                                Text("No results from Watchlist")
                            }
                        } header: {
                            Text("Results from Watchlist")
                        }
                        Section {
                            if !searchVM.items.isEmpty {
                                ForEach(searchVM.items) { item in
                                    NavigationLink(value: item) {
                                        SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isInWatchlist)
                                    }
                                }
                            } else {
                                Text("No results from TMDb")
                            }
                        } header: {
                            Text("Results from TMDb")
                        }
                    }
                } else if items.isEmpty {
                    Text("Your list is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
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
                        case .pin:
                            WatchlistSectionView(items: items.filter { $0.isPin },
                                                 title: "Pins")
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .disableAutocorrection(true)
            .searchable(text: $query)
            .task(id: query) {
                if query.isEmpty { return }
                if Task.isCancelled { return }
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                await searchVM.search(query)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showPicker = true
                    }, label: {
                        Label("Sort List",
                              systemImage: "line.3.horizontal.decrease.circle.fill")
                    })
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .padding(.bottom)
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(id: item.itemId,
                                title: item.itemTitle,
                                type: item.itemMedia,
                                image: item.itemImage)
            }
            .navigationDestination(for: ItemContent.self) { item in
                if item.media == .person {
                    PersonView(id: item.id, name: item.itemTitle)
                } else {
                    ItemContentView(id: item.id,
                                    title: item.itemTitle,
                                    type: item.itemContentMedia,
                                    image: item.cardImageMedium)
                }
            }
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    VStack {
                        ScrollView {
                            ForEach(DefaultListTypes.allCases) { list in
                                Button(action: {
                                    selectedOrder = list
                                    showPicker = false
                                }, label: {
                                    Text(list.title)
                                })
                            }
                        }
                    }
                    .navigationTitle("Sort List")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showPicker = false }
                        }
                    }
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
