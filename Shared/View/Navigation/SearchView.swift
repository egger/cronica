//
//  SearchView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct SearchView: View {
#if !os(macOS)
    static let tag: Screens? = .search
#endif
#if os(tvOS)
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 260))]
#endif
    @StateObject private var viewModel = SearchViewModel()
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    @State private var scope: SearchItemsScope = .noScope
    @State private var currentlyQuery = String()
    var body: some View {
        VStack {
#if os(iOS)
            listView
#elseif os(tvOS)
            posterView
#endif
        }
#if !os(tvOS)
        .navigationTitle("Search")
#endif
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(name: person.name, id: person.id)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: ProductionCompany.self) { item in
            CompanyDetails(company: item)
        }
        .navigationDestination(for: [ProductionCompany].self) { item in
            CompaniesListView(companies: item)
        }
        .navigationDestination(for: SearchItemContent.self) { item in
            if item.media == .person {
                PersonDetailsView(name: item.itemTitle, id: item.id)
            } else {
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
            }
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let title = item.map { (key, _) in key }.first
            let items = item.map { (_, value) in value }.first
            if let title, let items {
                ItemContentSectionDetails(title: title, items: items)
            }
        }
        .navigationDestination(for: [Person].self) { items in
            DetailedPeopleList(items: items)
        }
        .navigationDestination(for: CombinedKeywords.self) { keyword in
            KeywordSectionView(keyword: keyword)
        }
#if os(iOS)
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Movies, Shows, People"))
        .searchScopes($scope) {
            ForEach(SearchItemsScope.allCases) { scope in
                Text(scope.localizableTitle).tag(scope)
            }
        }
#else
        .searchable(text: $viewModel.query, prompt: "Movies, Shows, People")
#endif
        .disableAutocorrection(true)
        .task(id: viewModel.query) {
            if currentlyQuery != viewModel.query {
                currentlyQuery = viewModel.query
                await viewModel.search(viewModel.query)
            }
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }
    
#if !os(tvOS)
    @ViewBuilder
    private var listView: some View {
        switch viewModel.stage {
        case .none:
            ScrollView {
                VStack {
                    TrendingKeywordsListView()
                        .environmentObject(viewModel)
                    Spacer()
                }
            }
        case .searching: searchingView
        case .empty: emptyView
        case .failure: failureView
        case .success:
            List {
                switch scope {
                case .noScope:
                    ForEach(viewModel.items) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                    if !viewModel.items.isEmpty {
                        loadableProgressRing
                    }
                case .movies:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                    loadableProgressRing
                case .shows:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                    loadableProgressRing
                case .people:
                    ForEach(viewModel.items.filter { $0.media == .person }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                    loadableProgressRing
                }
            }
        }
    }
#endif
    
#if os(tvOS)
    @ViewBuilder
    private var posterView: some View {
        switch viewModel.stage {
        case .none: TrendingKeywordsListView()
        case .searching: searchingView
        case .empty: emptyView
        case .failure: failureView
        case .success:
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.items) { item in
                        if item.media == .person {
                            PersonSearchImage(item: item)
                                .padding()
                        } else {
                            SearchContentPosterView(item: item,
                                                    showPopup: $showPopup,
                                                    popupType: $popupType)
                            .padding()
                        }
                    }
                    .buttonStyle(.plain)
                    if viewModel.startPagination && !viewModel.endPagination {
                        CenterHorizontalView {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            viewModel.loadMoreItems()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .horizontal)
        }
    }
#endif
    
    private var emptyView: some View {
        ContentUnavailableView("No Results", systemImage: "magnifyingglass").padding()
    }
    
    private var searchingView: some View {
        ProgressView("Searching")
            .foregroundColor(.secondary)
            .padding()
    }
    
    private var failureView: some View {
        ContentUnavailableView("Search failed, try again later.", systemImage: "magnifyingglass").padding()
    }
    
    @ViewBuilder
    private var loadableProgressRing: some View {
        if viewModel.startPagination && !viewModel.endPagination {
            CenterHorizontalView {
                ProgressView()
                    .padding()
                    .onAppear(perform: loadMoreOnAppear)
            }
        }
    }
}

#Preview {
    SearchView()
}

extension SearchView {
    private func loadMoreOnAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.loadMoreItems()
        }
    }
}
