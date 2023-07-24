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
    @State private var isSyncing = false
    @State private var isImportingList = false
    @State private var itemsToSync = [TMDBItemContent]()
    @State private var itemsToAddToCustomList = [ItemContent]()
    @State private var hasLoaded = false
    @State private var deleteConfirmation = false
    @State private var isDeleted = false
    var body: some View {
        Form {
            Section {
                if items.isEmpty {
                    Text("Empty List")
                } else {
                    ForEach(items) { item in
                        ItemContentRowView(item: item)
                    }
                }
            } header: {
                Text("Items")
            }
        }
        .overlay { if isLoading { CenterHorizontalView { ProgressView("Loading") } }}
        .overlay {
            if isDeleted {
                CenterVerticalView {
                    Text("listDeleted")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("areYouSure", isPresented: $deleteConfirmation) {
            Button("Confirm", role: .destructive) {
                delete()
            }
        } message: {
            Text("deleteConfirmationMessage")
        }
        .toolbar {
            #if !os(tvOS)
            ToolbarItem {
                Menu {
                    deleteButton
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
            #endif
        }
        .navigationTitle(list.itemTitle)
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle,
                               id: item.id,
                               type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
            ItemContentSectionDetails(title: keys[0], items: value[0])
        }
        .navigationDestination(for: [Person].self) { items in
            DetailedPeopleList(items: items)
        }
        .navigationDestination(for: ProductionCompany.self) { item in
            CompanyDetails(company: item)
        }
        .navigationDestination(for: [ProductionCompany].self) { item in
            CompaniesListView(companies: item)
        }
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
            await MainActor.run { withAnimation { self.isLoading = false } }
            hasLoaded = true
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
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            deleteConfirmation.toggle()
        } label: {
            Text("deleteList")
                .foregroundColor(.red)
        }
    }
    
    private func delete() {
        Task {
            let deletionStatus = await viewModel.deleteList(list.id)
            await MainActor.run {
                withAnimation {
                    items = []
                    isDeleted = deletionStatus
                }
            }
        }
    }
    
    private func importList() async {
        do {
            await MainActor.run { withAnimation { isImportingList = true } }
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
                let savedItem = persistence.fetch(for: item.itemContentID)
                if let savedItem {
                    itemsToAdd.insert(savedItem)
                }
            }
            list.items = itemsToAdd as NSSet
            if viewContext.hasChanges {
                try viewContext.save()
                HapticManager.shared.successHaptic()
            }
            await MainActor.run { withAnimation { isImportingList = false } }
            await MainActor.run { withAnimation { self.syncList = true } }
        } catch {
            if Task.isCancelled { return }
        }
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
