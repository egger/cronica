//
//  TMDBListDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI

struct TMDBListDetails: View {
    let list: TMDBListResult
    @State var viewModel = ExternalWatchlistManager.shared
    @State private var syncList = false
    @State private var detailedList: DetailedTMDBList?
    @State private var items = [ItemContent]()
    @State private var isLoading = true
    @FetchRequest(
        entity: CustomList.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CustomList.title, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "isSyncEnabledTMDB == %d", true),
        ])
    ) private var customLists: FetchedResults<CustomList>
    @State private var selectedCustomList: CustomList?
    @State private var isSyncing = false
    @State private var isImportingList = false
    @State private var itemsToSync = [TMDBItemContent]()
    var body: some View {
        Form {
            if isLoading {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                Section {
                    if syncList {
                        syncButton
                    } else {
                        importButton
                    }
                } header: {
                    Text("tmdbListSyncConfig")
                }
                
                Section {
                    if items.isEmpty {
                        Text("emptyList")
                    } else {
                        ForEach(items) { item in
#if os(iOS)
                            NavigationLink(destination: ItemContentDetails(title: item.itemTitle,
                                                                           id: item.id,
                                                                           type: item.itemContentMedia)) {
                                ItemContentRow(item: item)
                            }
#else
                            Text(item.itemTitle)
#endif
                        }
                    }
                } header: {
                    Text("Items")
                }
                .redacted(reason: isSyncing ? .placeholder : [])
                .redacted(reason: isImportingList ? .placeholder : [])
            }
        }
        .navigationTitle(list.itemTitle)
        .onAppear {
            Task {
                detailedList = await viewModel.fetchList(id: list.id)
                if let detailedList {
                    print("Detailed list from TMDBListDetails: \(detailedList)")
                }
                if !items.isEmpty { return }
                if let content = detailedList?.results {
                    items = content
                }
                guard let listID = detailedList?.id else {
                    withAnimation { self.isLoading = false }
                    return
                }
                for item in customLists {
                    if item.tmdbListId == Int64(listID) {
                        syncList = true
                        selectedCustomList = item
                    }
                }
                withAnimation { self.isLoading = false }
            }
        }
    }
    
    private var importButton: some View {
        Button {
            Task { await importList() }
        } label: {
            if isImportingList {
                CenterHorizontalView { ProgressView() }
            } else {
                Text("importTMDBList")
            }
        }
    }
    
    private var syncButton: some View {
        Button {
            Task { await sync() }
        } label: {
            if isSyncing {
                CenterHorizontalView { ProgressView("syncInProgress") }
            } else {
                Text("syncNow")
            }
        }
    }
    
    private func importList() async {
        do {
            DispatchQueue.main.async { withAnimation { isImportingList = true } }
            let persistence = PersistenceController.shared
            let network = NetworkService.shared
            let viewContext = persistence.container.viewContext
            let list = CustomList(context: viewContext)
            list.id = UUID()
            list.title = self.list.itemTitle
            list.creationDate = Date()
            list.updatedDate = Date()
            list.isSyncEnabledTMDB = true
            list.tmdbListId = Int64(self.list.id)
            var itemsToAdd = Set<WatchlistItem>()
            for item in items {
                let content = try await network.fetchItem(id: item.id, type: item.itemContentMedia)
                persistence.save(content)
                let savedItem = try? persistence.fetch(for: Int64(item.id), media: item.itemContentMedia)
                if let savedItem {
                    itemsToAdd.insert(savedItem)
                }
            }
            list.items = itemsToAdd as NSSet
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                    HapticManager.shared.successHaptic()
                } catch {
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "TMDBListDetails.importList.failed")
                }
            }
            DispatchQueue.main.async { withAnimation { isImportingList = false } }
            DispatchQueue.main.async { withAnimation { self.syncList = true } }
        } catch {
            if Task.isCancelled { return }
        }
    }
    
    private func checkForSync() {
        var itemsToAdd = [TMDBItemContent]()
        guard let selectedCustomList else { return }
        for item in selectedCustomList.itemsArray {
            if !items.contains(where: { $0.id == item.itemId}) {
                let content = TMDBItemContent(media_type: item.itemMedia.rawValue, media_id: item.itemId)
                itemsToAdd.append(content)
            }
        }
        itemsToSync = itemsToAdd
    }
    
    private func sync() async {
        if itemsToSync.isEmpty { return }
        withAnimation { self.isSyncing = true }
        let itemsToUpdate = TMDBItem(items: itemsToSync)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let jsonData = try encoder.encode(itemsToUpdate)
            await viewModel.updateList(list.id, with: jsonData)
        } catch {
            print(error.localizedDescription)
        }
        withAnimation { self.isSyncing = false }
    }
}
