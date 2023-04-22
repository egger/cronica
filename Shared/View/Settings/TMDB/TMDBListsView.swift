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
    var body: some View {
        VStack {
            List {
                ForEach(lists) { list in
                    NavigationLink(destination: TMDBListDetails(list: list, viewModel: $viewModel)) {
                        Text(list.itemTitle)
                    }
                }
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
                    }
                }
            }
        }
    }
}
