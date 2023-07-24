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
        Section {
            List {
                ForEach(items) { item in
                    ItemContentRowView(item: item)
                }
                if !isEndPagination && hasLoaded {
                    CenterHorizontalView {
                        ProgressView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    Task { await fetch() }
                                }
                            }
                    }
                }
            }
            .overlay { if items.isEmpty && hasLoaded { CenterHorizontalView { Text("emptyList") } }}
            .overlay { if !hasLoaded { CenterHorizontalView { ProgressView("Loading") }.unredacted() }}
            .redacted(reason: isImporting ? .placeholder : [])
        }
        .toolbar {
            ToolbarItem {
#if !os(tvOS)
                Menu {
                    if !settings.userImportedTMDB {
                        importButton
                    } else {
                        syncButton
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
#endif
            }
        }
        .task { await load() }
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
                CenterHorizontalView { ProgressView("importingWatchlistTMDB") }
            } else {
                Text("importTMDBWatchlist")
            }
        }
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
            await MainActor.run { settings.userImportedTMDB = true }
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
    }
    
    
    private func publishItems() async {
        do {
            let context = PersistenceController.shared.container.newBackgroundContext()
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            let list = try context.fetch(request)
            if list.isEmpty { return }
            await MainActor.run { withAnimation { self.isSyncing = true } }
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
            await MainActor.run { withAnimation { self.isSyncing = false } }
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
