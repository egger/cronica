//
//  TMDBListsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI

struct TMDBListsView: View {
    @Binding var viewModel: TMDBAccountManager
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
        .onAppear {
            if lists.isEmpty {
                Task {
                    let fetchedLists = await viewModel.fetchLists()
                    if let fetchedLists {
                        print("fetched lists from TMDBListsView: \(fetchedLists)")
                    }
                    if let result = fetchedLists?.results {
                        lists = result
                        withAnimation { self.isLoading = false }
                    }
                }
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var loadingSection: some View {
        Section {
            CenterHorizontalView { ProgressView("Loading") }
        }
    }
    
    private var listsSection: some View {
        Section {
            List {
                ForEach(lists) { list in
                    NavigationLink(destination: TMDBListDetails(list: list, viewModel: $viewModel)) {
                        Text(list.itemTitle)
                    }
                }
            }
        }
    }
}
