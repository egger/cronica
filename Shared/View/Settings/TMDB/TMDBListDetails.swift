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
    @State private var itemsToAddToCustomList = [ItemContent]()
    @State private var hasLoaded = false
    @State private var deleteConfirmation = false
    @State private var isDeleted = false
    var body: some View {
        Form {
            if isLoading {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                if isDeleted {
                    CenterVerticalView {
                        Text("listDeleted")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Section {
                        if syncList {
                            syncWarning
                            syncButton
                        } else {
                            importButton
                        }
                        deleteButton
                    }
                    .alert("areYouSure", isPresented: $deleteConfirmation) {
                        Button("Confirm", role: .destructive) {
                            delete()
                        }
                    } message: {
                        Text("deleteConfirmationMessage")
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
                                ItemContentRow(item: item)
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
        }
        .navigationTitle(list.itemTitle)
        .onAppear { Task { await load() } }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        detailedList = await viewModel.fetchListDetails(for: list.id)
        if !items.isEmpty { return }
        if let content = detailedList?.results {
            items = content
        }
        if !hasLoaded {
            guard let listID = detailedList?.id else {
                DispatchQueue.main.async { withAnimation { self.isLoading = false } }
                return
            }
            for item in customLists {
                if item.idOnTMDb == Int64(listID) {
                    syncList = true
                    selectedCustomList = item
                }
            }
            DispatchQueue.main.async { withAnimation { self.isLoading = false } }
            hasLoaded = true
        }
        checkForSync()
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
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
    private var deleteButton: some View {
        Button {
            deleteConfirmation.toggle()
        } label: {
            Text("deleteList")
                .foregroundColor(.red)
        }
#if os(macOS)
        .buttonStyle(.link)
#endif
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
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
    private func delete() {
        Task {
            if let selectedCustomList {
                selectedCustomList.isSyncEnabledTMDB = false
                selectedCustomList.idOnTMDb = 0
                let viewContext = PersistenceController.shared.container.viewContext
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        if Task.isCancelled { return }
                    }
                }
            }
            let deletionStatus = await viewModel.deleteList(list.id)
            DispatchQueue.main.async {
                withAnimation { isDeleted = deletionStatus }
            }
        }
    }
    
    @ViewBuilder
    private var syncWarning: some View {
        if !itemsToSync.isEmpty {
            Text("needToSync \(itemsToSync.count)")
                .foregroundColor(.red)
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
            list.idOnTMDb = Int64(self.list.id)
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
                try viewContext.save()
                HapticManager.shared.successHaptic()
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
        DispatchQueue.main.async { withAnimation { self.isSyncing = true } }
        let itemsToUpdate = TMDBItem(items: itemsToSync)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let jsonData = try encoder.encode(itemsToUpdate)
            await viewModel.updateList(list.id, with: jsonData)
            self.items = []
            await load()
        } catch {
            if Task.isCancelled { return }
        }
        DispatchQueue.main.async { withAnimation { self.isSyncing = false } }
    }
}
