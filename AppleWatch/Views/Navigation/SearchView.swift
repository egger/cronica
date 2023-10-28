//
//  SearchView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 07/08/23.
//

import SwiftUI

struct SearchView: View {
    static let tag: Screens? = .search
    private let service: NetworkService = NetworkService.shared
    @State private var trending = [ItemContent]()
    @State private var isLoaded = false
    
    // search
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
                    Section("Trending") {
                        List {
                            ForEach(trending) { item in
                                NavigationLink(value: item) {
                                    ItemContentRow(item: item)
                                }
                            }
                        }
                        .redacted(reason: isLoaded ? [] : .placeholder)
                    }
                } else {
                    searchResults
                }
                
            }
			.overlay { if !isLoaded { ProgressView().unredacted() } }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query)
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
                    PersonDetailsView(name: item.itemTitle, id: item.id)
                } else {
                    ItemContentView(id: item.id,
                                    title: item.itemTitle,
                                    type: item.itemContentMedia,
                                    image: item.cardImageMedium)
                }
            }
            .onAppear(perform: load)
        }
    }
    
    private func load() {
        Task {
            if !isLoaded {
                if trending.isEmpty {
                    do {
                        let result = try await service.fetchItems(from: "trending/all/day")
                        let filtered = result.filter { $0.itemContentMedia != .person }
                        trending = filtered
                        isLoaded = true
                    } catch {
                        if Task.isCancelled { return }
                        let message = "Can't load trending/all/day, error: \(error.localizedDescription)"
                        CronicaTelemetry.shared.handleMessage(message, for: "SearchView.load()")
                    }
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

#Preview {
    SearchView()
}
