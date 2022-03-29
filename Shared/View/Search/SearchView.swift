//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct SearchView: View {
    static let tag: String? = "Search"
    @StateObject private var viewModel: SearchViewModel
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.searchItems) { item in
                    if item.media == MediaType.person {
                        NavigationLink(destination: CastDetailsView(title: item.itemTitle, id: item.id)) {
                            ItemView(title: item.itemTitle, url: item.itemImage, type: item.media, inSearch: true)
                        }
                    } else {
                        NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.id, type: item.media)) {
                            ItemView(title: item.itemTitle, url: item.itemImage, type: item.media, inSearch: true)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Movies, Shows, People") )
            .disableAutocorrection(true)
            .overlay(overlayView)
            .onAppear { viewModel.observe() }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .empty:
            if viewModel.trimmedQuery.isEmpty {
                VStack {
                    Spacer()
                    AttributionView()
                }
            } else {
                ProgressView("Searching")
                    .foregroundColor(.secondary)
            }
        case .success(let values) where values.isEmpty:
            Label("No Results", systemImage: "minus.magnifyingglass")
                .font(.title)
                .foregroundColor(.secondary)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: {
                Task {
                    await viewModel.search(query: viewModel.query)
                }
            })
        default: EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
