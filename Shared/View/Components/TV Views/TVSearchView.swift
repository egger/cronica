//
//  SearchView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVSearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    var body: some View {
        VStack {
            switch viewModel.stage {
            case .none:
                VStack { }
            case .searching:
                ProgressView("Searching")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
                    .padding()
            case .empty:
                Label("No Results", systemImage: "minus.magnifyingglass")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
                    .padding()
            case .failure:
                VStack {
                    Text("Search failed, try again later.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontDesign(.monospaced)
                        .padding()
                }
            case .success:
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.items) { item in
                            TVSearchItemContentView(item: item)
                                .padding(.vertical)
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
        .navigationDestination(for: ItemContent.self) { item in
            if item.media == .person {
                PersonDetailsView(title: item.itemTitle, id: item.id)
            } else {
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
        }
    }
}
#endif
