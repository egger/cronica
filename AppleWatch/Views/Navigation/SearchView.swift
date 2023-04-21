//
//  SearchView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @Binding var query: String
    @State private var filteredItems = [WatchlistItem]()
    @State private var isInWatchlist = false
    var body: some View {
        List {
            Section {
                if !filteredItems.isEmpty {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            WatchlistItemRow(content: item)
                        }
                    }
                } else {
                    Text("No results from Watchlist")
                }
            } header: {
                Text("Results from Watchlist")
            }
            Section {
                if !viewModel.items.isEmpty {
                    ForEach(viewModel.items) { item in
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
        .task(id: query) {
            if query.isEmpty { return }
            if Task.isCancelled { return }
            if !filteredItems.isEmpty { filteredItems.removeAll() }
            filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
            await viewModel.search(query)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    @State private static var query = String()
    static var previews: some View {
        SearchView(query: $query)
    }
}
