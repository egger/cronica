//
//  SearchView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var isInWatchlist = false
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.items) { item in
                        NavigationLink(value: item) {
                            SearchItem(item: item, isInWatchlist: $isInWatchlist)
                        }
                    }
                }
            }
            .task(id: viewModel.query) {
                await viewModel.search(viewModel.query)
            }
            .overlay(searchResults)
            .navigationTitle("Search")
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer, prompt: "Search")
            .navigationDestination(for: ItemContent.self) { item in
                if item.media == .person {
                    PersonView(id: item.id, name: item.itemTitle)
                } else {
                    ItemContentView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                }
            }
            .disableAutocorrection(true)
        }
    }
    
    @ViewBuilder
    private var searchResults: some View {
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
        case .success: EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
