//
//  ContentView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 02/08/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredMovieItems: [WatchlistItem] {
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
                    if !filteredMovieItems.isEmpty {
                        List(filteredMovieItems) { item in
                            NavigationLink(value: item) {
                                WatchlistItemWatch(item: item)
                            }
                        }
                    } else if !query.isEmpty && filteredMovieItems.isEmpty {
                        Text("No results found.")
                    } else {
                        List(items) { item in
                            NavigationLink(value: item) {
                                WatchlistItemWatch(item: item)
                            }
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
                ItemContentView(id: item.itemId, title: item.itemTitle, mediaType: item.itemMedia)
            }
            .navigationDestination(for: Screens.self) { screen in
                if screen == .search {
                    SearchView()
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private struct WatchlistItemWatch: View {
    let item: WatchlistItem
    private let context = PersistenceController.shared
    var body: some View {
        ItemView(content: item)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive) {
                    context.delete(item)
                }
            }
    }
}
