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
                HStack {
                    Text("Items")
                    Spacer()
                    Text("\(items.count)")
                }
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
