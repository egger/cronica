//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct SearchView: View {
    static let tag: String? = "Search"
    @State private var query: String = ""
    @StateObject private var viewModel = SearchViewModel()
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.searchItems) { item in
                    //Text(item.itemTitle)
                    NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.media)) {
                        ItemView(title: item.itemTitle, url: item.image, type: item.media)
                    }
                }
                
            }
#if os(iOS)
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Movies, Shows, People") )
#elseif os(macOS)
            .searchable(text: $query, prompt: Text("Movies, Shows, People"))
#endif
            .navigationTitle("Search")
#if os(iOS)
            .navigationViewStyle(.stack)
#endif
            .overlay(overlayView)
            .onAppear { viewModel.observe() }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
            
        case .empty:
            if viewModel.trimmedQuery.isEmpty {
                EmptyView()
            } else {
                ProgressView()
            }
            
        case .success(let values) where values.isEmpty:
            Text("No Results")
            
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
