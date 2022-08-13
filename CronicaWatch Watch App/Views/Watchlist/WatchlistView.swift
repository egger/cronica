//
//  WatchlistView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
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
                                ItemView(content: item)
                            }
                        }
                    } else if !query.isEmpty && filteredItems.isEmpty {
                        Text("No results found.")
                    } else {
                        List {
                            WatchlistSectionView(items: items.filter { $0.isReleasedMovie || $0.isReleasedTvShow }, title: "Released")
                            WatchlistSectionView(items: items.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow },
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
            .searchable(text: $query, prompt: "Search Watchlist")
            .toolbar {
                ToolbarItem {
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
