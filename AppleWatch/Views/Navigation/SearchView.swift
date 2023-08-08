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
    @State private var hasLoadedTMDbResults = false
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        List {
            if !filteredItems.isEmpty {
                Section("Results from Watchlist") {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            WatchlistItemRowView(content: item, showPopup: $showPopup, popupType: $popupType)
                        }
                    }
                }
            }
            
            Section("Results from TMDb") {
                if hasLoadedTMDbResults {
                    if !viewModel.items.isEmpty {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item) {
                                SearchItem(item: item)
                            }
                        }
                    } else {
                        Text("No results from TMDb")
                    }
                } else {
                    ProgressView("Loading")
                }
            }
        }
        .task(id: query) {
            if query.isEmpty { return }
            if Task.isCancelled { return }
            withAnimation { hasLoadedTMDbResults = false }
            if !filteredItems.isEmpty { filteredItems.removeAll() }
            filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
            await viewModel.search(query)
            withAnimation { hasLoadedTMDbResults = true }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(query: .constant(String()))
    }
}
