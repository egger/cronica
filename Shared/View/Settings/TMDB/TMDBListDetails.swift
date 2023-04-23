//
//  TMDBListDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI

struct TMDBListDetails: View {
    let list: TMDBListResult
    @Binding var viewModel: TMDBAccountManager
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
    ) var customLists: FetchedResults<CustomList>
    var body: some View {
        Form {
            if isLoading {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                Section {
                    if syncList {
                        Button("syncNow") { sync() }
                    } else {
                        Button("importListTMDB") { importList() }
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
                    }
                }
                withAnimation { self.isLoading = false }
            }
        }
    }
    
    private func importList() {
        let persistence = PersistenceController.shared
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
            persistence.save(item)
            let savedItem = try? persistence.fetch(for: Int64(item.id), media: item.itemContentMedia)
            if let savedItem {
                itemsToAdd.insert(savedItem)
            }
        }
        list.items = itemsToAdd as NSSet
        print(list as Any)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                HapticManager.shared.successHaptic()
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "TMDBListDetails.importList.failed")
            }
        }
        self.syncList = true
    }
    
    private func sync() {
        
    }
}
