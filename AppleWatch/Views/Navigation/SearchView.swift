//
//  SearchView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct SearchView: View {
    static let tag: Screens? = .search
    @StateObject private var viewModel = SearchViewModel()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = String()
    @State private var filteredItems = [WatchlistItem]()
    @State private var isInWatchlist = false
    @State private var hasLoadedTMDbResults = false
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        NavigationStack {
            Form {
                if query.isEmpty {
                    HStack {
                        Spacer()
                        Text("Search Your Watchlist and TMDB Content")
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    searchResults
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, placement: .toolbar)
            .task(id: query) {
                if query.isEmpty { return }
                if Task.isCancelled { return }
                withAnimation { hasLoadedTMDbResults = false }
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                await viewModel.search(query)
                withAnimation { hasLoadedTMDbResults = true }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(id: item.itemId,
                                title: item.itemTitle,
                                type: item.itemMedia,
                                image: item.backCompatibleCardImage)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentView(id: item.id,
                                title: item.itemTitle,
                                type: item.itemContentMedia,
                                image: item.cardImageMedium)
            }
            .navigationDestination(for: SearchItemContent.self) { item in
                if item.media == .person {
                    PersonView(id: item.id, name: item.itemTitle)
                } else {
                    ItemContentView(id: item.id,
                                    title: item.itemTitle,
                                    type: item.itemContentMedia,
                                    image: item.cardImageMedium)
                }
            }
        }
    }
    
    private var searchResults: some View {
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
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
