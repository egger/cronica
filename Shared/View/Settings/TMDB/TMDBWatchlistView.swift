//
//  TMDBWatchlistView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/23.
//

import SwiftUI
import CoreData

struct TMDBWatchlistView: View {
    @State private var isImporting = false
    @State private var viewModel = ExternalWatchlistManager.shared
    @State private var settings = SettingsStore.shared
    @State private var items = [ItemContent]()
    @State private var hasLoaded = false
    @State private var isSyncing = false
    @State private var page = 1
    @State private var isEndPagination = false
    @State private var selectedItem: ItemContent?
    var body: some View {
        Form {
            if !hasLoaded {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                Section {
                    if !settings.userImportedTMDB {
                        importButton
                    } else {
                        syncButton
                    }
                }
                
                Section {
                    if items.isEmpty {
                        CenterHorizontalView { Text("emptyList") }
                    } else {
                        List {
                            ForEach(items) { item in
                                Button {
                                    selectedItem = item
                                } label: {
                                    ItemContentConfirmationRow(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                            if !isEndPagination {
                                ProgressView()
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            Task { await fetch() }
                                        }
                                    }
                            }
                        }
                        .redacted(reason: isImporting ? .placeholder : [])
                    }
                } header: {
                    Text("itemsTMDB")
                }
                .sheet(item: $selectedItem) { item in
                    NavigationStack {
#if os(iOS)
                        ItemContentDetails(title: item.itemTitle,
                                           id: item.id,
                                           type: item.itemContentMedia)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) { doneButton }
                        }
#elseif os(macOS)
                        ItemContentDetailsView(id: item.id,
                                               title: item.itemTitle,
                                               type: item.itemContentMedia,
                                               handleToolbarOnPopup: true)
                        .toolbar { doneButton }
#endif
                    }
                    .presentationDetents([.large])
#if os(macOS)
                    .frame(width: 600, height: 400, alignment: .center)
#endif
                }
                
            }
        }
        .navigationTitle("AccountSettingsViewWatchlist")
        .task {
            await load()
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        if hasLoaded { return }
        await fetch()
        withAnimation { self.hasLoaded = true }
    }
    
    private var importButton: some View {
        Button {
            Task { await saveWatchlist() }
        } label: {
            if isImporting {
                CenterHorizontalView { ProgressView("importingTMDB") }
            } else {
                Text("importTMDBWatchlist")
            }
        }
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
    private var doneButton: some View {
        Button("Done") { selectedItem = nil }
    }
    
    private func saveWatchlist() async {
        do {
            withAnimation { self.isImporting = true }
            let network = NetworkService.shared
            while (isEndPagination == false) {
                await fetch()
            }
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
            Task { await publishItems() }
        } label: {
            if isSyncing {
                CenterHorizontalView { ProgressView("syncingWatchlistTMDB") }
            } else {
                Text("syncWatchlist")
            }
        }
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
    private func publishItems() async {
        do {
            let context = PersistenceController.shared.container.newBackgroundContext()
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            let list = try context.fetch(request)
            if list.isEmpty { return }
            DispatchQueue.main.async { withAnimation { self.isSyncing = true } }
            for item in list {
                if !items.contains(where: { $0.id == item.itemId }) {
                    let content = TMDBWatchlistItemV3(media_type: item.itemMedia.rawValue,
                                                      media_id: item.itemId,
                                                      watchlist: true)
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.sortedKeys]
                    let data = try encoder.encode(content)
                    await viewModel.updateWatchlist(with: data)
                }
            }
            await fetch(shouldReload: true)
            DispatchQueue.main.async { withAnimation { self.isSyncing = false } }
        } catch {
            if Task.isCancelled { return }
        }
    }
    
    
    private func fetch(shouldReload: Bool = false) async {
        if shouldReload {
            self.page = 1
            self.items = []
        }
        if !self.items.isEmpty { self.page += 1 }
        let movies = await viewModel.fetchWatchlist(type: .movie, page: page)
        let shows = await viewModel.fetchWatchlist(type: .tvShow, page: page)
        guard let moviesResult = movies?.results, let showsResult = shows?.results else { return }
        let result = moviesResult + showsResult
        if result.isEmpty { self.isEndPagination = true }
        items.append(contentsOf: result)
    }
    
}
