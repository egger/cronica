//
//  TMDBListsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI

struct TMDBListsView: View {
    @State private var viewModel = ExternalWatchlistManager.shared
    @State private var lists = [TMDBListResult]()
    @State private var isLoading = true
    var body: some View {
        Form {
            if isLoading {
                loadingSection
            } else {
                listsSection
            }
        }
        .navigationTitle("tmdbLists")
        .task {
            await load()
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        let fetchedLists = await viewModel.fetchLists()
        if let result = fetchedLists?.results {
            lists = result
            withAnimation { self.isLoading = false }
        }
    }
    
    private var loadingSection: some View {
        Section {
            CenterHorizontalView { ProgressView("Loading") }
        }
    }
    
    private var listsSection: some View {
        Section {
            List {
                if lists.isEmpty {
                    CenterHorizontalView {
                        Text("emptyLists")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(lists) { list in
                        NavigationLink(destination: TMDBListDetails(list: list)) {
                            Text(list.itemTitle)
                        }
                    }
                }
            }
        }
    }
}
