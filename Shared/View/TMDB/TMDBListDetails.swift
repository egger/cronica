//
//  TMDBListDetails.swift
//  Cronica (iOS)
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
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    
    // pagination
    @State private var page = 1
    @State private var endPagination = false
    @State private var totalItems = 0
    var body: some View {
        Form {
            if !isDeleted {
                Section {
                    if items.isEmpty {
                        EmptyListView()
                    } else {
                        ForEach(items) { item in
                            ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
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
        .actionPopup(isShowing: $showPopup, for: popupType)
        .overlay { if isLoading { CenterHorizontalView { ProgressView("Loading") } }}
        .overlay {
            if isDeleted {
                VStack {
                    if #available(iOS 17, *), #available(watchOS 10, *), #available(tvOS 17, *), #available(macOS 14, *) {
                        ContentUnavailableView("Deleted", systemImage: "trash")
                    } else {
                        Text("Deleted")
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .alert("Are you sure?", isPresented: $deleteConfirmation) {
            Button("Confirm", role: .destructive) {
                delete()
            }
        } message: {
            Text("This action can't be undone.\nThis will not delete the local list, just the one on TMDb.")
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
    
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            deleteConfirmation.toggle()
        } label: {
            Text("Delete")
                .foregroundColor(.red)
        }
    }
}

extension TMDBListDetails {
    @MainActor
    private func load() async {
        detailedList = await viewModel.fetchListDetails(for: list.id, page: page)
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
        if !hasLoaded {
            await MainActor.run { withAnimation { self.isLoading = false } }
            hasLoaded = true
        }
    }
    
    @MainActor
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
