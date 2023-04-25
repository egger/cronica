//
//  TMDBWatchlistView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/23.
//

import SwiftUI

struct TMDBWatchlistView: View {
    @State private var isImporting = false
    @State private var viewModel = ExternalWatchlistManager.shared
    @State private var settings = SettingsStore.shared
    @State private var items = [ItemContent]()
    @State private var hasLoaded = false
    var body: some View {
        Form {
            if !hasLoaded {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                if !settings.userImportedTMDB {
                    Section {
                        importButton
                    }
                } else {
                    Section {
                        syncButton
                    }
                }
                
                Section {
                    if items.isEmpty {
                        CenterHorizontalView { Text("emptyList") }
                    } else {
                        List {
                            ForEach(items) { item in
                                ItemContentRow(item: item)
                            }
                        }
                        .redacted(reason: isImporting ? .placeholder : [])
                    }
                } header: {
                    Text("itemsTMDB")
                }
                
            }
        }
        .navigationTitle("watchlistTMDB")
        .task {
            await load()
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        if hasLoaded { return }
        let movies = await viewModel.fetchWatchlist(type: .movie)
        let shows = await viewModel.fetchWatchlist(type: .tvShow)
        guard let moviesResult = movies?.results, let showsResult = shows?.results else { return }
        let result = moviesResult + showsResult
        items = result
        withAnimation { self.hasLoaded = true }
    }
    
    private var importButton: some View {
        Button {
            Task { await saveWatchlist() }
        } label: {
            if isImporting {
               ProgressView("importingTMDB")
            } else {
                Text("importTMDBWatchlist")
            }
        }
    }
    
    private func saveWatchlist() async {
        do {
            withAnimation { self.isImporting = true }
            let network = NetworkService.shared
            for item in items {
                let content = try await network.fetchItem(id: item.id, type: item.itemContentMedia)
                PersistenceController.shared.save(content)
            }
            withAnimation { self.isImporting = false }
            DispatchQueue.main.async { settings.userImportedTMDB = true }
        } catch {
            if Task.isCancelled { return }
        }
    }
    
    private var syncButton: some View {
        Button {
            
        } label: {
            Text("syncNow")
        }
    }
}
