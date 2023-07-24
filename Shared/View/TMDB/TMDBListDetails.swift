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
    @State private var hasLoaded = false
    @State private var deleteConfirmation = false
    @State private var isDeleted = false
    
    // pagination
    @State private var page = 1
    @State private var endPagination = false
    @State private var totalItems = 0
    var body: some View {
        Form {
            if !isDeleted {
                Section {
                    if items.isEmpty {
                        Text("Empty List")
                    } else {
                        ForEach(items) { item in
                            ItemContentRowView(item: item)
                        }
                        if !endPagination {
                            CenterHorizontalView {
                                ProgressView()
                                    .foregroundColor(.secondary)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            page += 1
                                            Task { await load() }
                                        }
                                    }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("\(totalItems) Items")
                        Spacer()
                    }
                }
            }
        }
        .overlay { if isLoading { CenterHorizontalView { ProgressView("Loading") } }}
        .overlay {
            if isDeleted {
                VStack {
                    Text("listDeleted")
                        .font(.title3)
                        .fontDesign(.rounded)
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
        .onAppear { if items.isEmpty { Task { await load() } } }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        detailedList = await viewModel.fetchListDetails(for: list.id, page: page)
        print("Current page: \(page)")
        guard let detailedList else { return }
        if let content = detailedList.results {
            items.append(contentsOf: content)
        }
        if let totalPages = detailedList.totalPages {
            if totalPages == page { endPagination = true }
        }
        if let totalResults = detailedList.totalResults {
            if totalResults != totalItems {
                totalItems = totalResults
            }
        }
        print(detailedList.sortBy as Any)
        print(detailedList.totalPages as Any)
        if !hasLoaded {
            await MainActor.run { withAnimation { self.isLoading = false } }
            hasLoaded = true
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
}
