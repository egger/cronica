//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct SearchView: View { 
    static let tag: Screens? = .search
    @StateObject private var viewModel: SearchViewModel
    @State private var showConfirmation: Bool = false
    @State private var scope: SearchItemsScope = .noScope
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        ZStack {
            List {
                switch scope {
                case .noScope:
                    ForEach(viewModel.items) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                            .draggable(item)
                    }
                    if viewModel.startPagination && !viewModel.endPagination {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.loadMoreItems()
                                    }
                                }
                            Spacer()
                        }
                    }
                case .movies:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                            .draggable(item)
                    }
                case .shows:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                            .draggable(item)
                    }
                case .people:
                    ForEach(viewModel.items.filter { $0.media == .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                            .draggable(item)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: ItemContent.self) { item in
                if item.media == .person {
                    PersonDetailsView(title: item.itemTitle, id: item.id)
                } else {
                    ItemContentView(title: item.itemTitle, id: item.id, type: item.media)
                }
            }
            .searchable(text: $viewModel.query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Movies, Shows, People"))
            .searchScopes($scope) {
                ForEach(SearchItemsScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .disableAutocorrection(true)
            .task(id: viewModel.query) {
                await viewModel.search(viewModel.query)
            }
            .overlay(searchResults)
            ConfirmationDialogView(showConfirmation: $showConfirmation)
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
