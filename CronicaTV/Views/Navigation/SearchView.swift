//
//  SearchView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showConfirmation = false
    var body: some View {
        VStack {
            switch viewModel.stage {
            case .none:
                VStack {
                    Spacer()
                    AttributionView()
                }
            case .searching:
                ProgressView("Searching")
                    .foregroundColor(.secondary)
                    .padding()
            case .empty:
                Label("No Results", systemImage: "minus.magnifyingglass")
                    .font(.title)
                    .foregroundColor(.secondary)
            case .failure:
                VStack {
                    Label("Search failed, try again later.", systemImage: "text.magnifyingglass")
                }
            case .success:
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item) {
                                SearchItemContentView(item: item)
                            }
                            .ignoresSafeArea(.all)
                            .buttonStyle(.card)
                        }
                        if viewModel.startPagination && !viewModel.endPagination {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.loadMoreItems()
                                    }
                                }

                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.query, prompt: "Movies, Shows, People")
        .task(id: viewModel.query) {
            await viewModel.search(viewModel.query)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
