//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct SearchView: View {
    static let tag: Screens? = .search
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @StateObject private var viewModel: SearchViewModel
    @State private var showConfirmation: Bool = false
    private let context = DataController.shared
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationStack {
                detailsView
            }
        } else {
           detailsView
        }
#else
        detailsView
#endif
    }
    
    var detailsView: some View {
        ZStack {
            List {
                ForEach(viewModel.searchItems) { item in
                    if item.media == MediaType.person {
                        SearchItemView(content: item, showConfirmation: $showConfirmation)
                    } else {
                        SearchItemView(content: item, showConfirmation: $showConfirmation)
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Movies, Shows, People"))
            .disableAutocorrection(true)
            .overlay(overlayView)
            .onAppear { viewModel.observe() }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
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
    
    private func updateWatchlist(item: ItemContent) {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id, type: item.media) {
            Task {
                let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.media)
                if let content = content {
                    withAnimation {
                        context.saveItem(content: content, notify: content.itemCanNotify)
                    }
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
