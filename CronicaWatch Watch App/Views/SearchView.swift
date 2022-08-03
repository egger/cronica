//
//  SearchView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.searchItems) { item in
                    NavigationLink(value: item) {
                        SearchItem(item: item)
                    }
                }
            }
        }
        .onAppear {
            viewModel.observe()
        }
        .overlay(overlayView)
        .navigationTitle("Search")
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer, prompt: "Search")
        .navigationDestination(for: ItemContent.self) { item in
            if item.media == .person {
                EmptyView()
            } else {
                ItemContentView(id: item.id, title: item.itemTitle, mediaType: item.itemContentMedia)
            }
        }
        .disableAutocorrection(true)
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .empty:
            if !viewModel.trimmedQuery.isEmpty {
                ProgressView("Searching")
                    .foregroundColor(.secondary)
                    .padding()
            }
        case .success(let values) where values.isEmpty:
            Label("No Results", systemImage: "minus.magnifyingglass")
                .font(.title)
                .foregroundColor(.secondary)
        case .failure(let error):
            Text(error.localizedDescription)
        default: EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
