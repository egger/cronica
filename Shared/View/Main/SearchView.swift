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
    private let context = PersistenceController.shared
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(viewModel.searchItems) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Person.self) { person in
                    CastDetailsView(title: person.name, id: person.id)
                }
                .navigationDestination(for: ItemContent.self) { item in
                    if item.media == .person {
                        CastDetailsView(title: item.itemTitle, id: item.id)
                    } else {
                        ContentDetailsView(title: item.itemTitle, id: item.id, type: item.media)
                    }
                }
                .searchable(text: $viewModel.query,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: Text("Movies, Shows, People"))
                .disableAutocorrection(true)
                .overlay(overlayView)
                .onAppear { viewModel.observe() }
                ConfirmationDialogView(showConfirmation: $showConfirmation)
            }
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
                    .padding()
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
