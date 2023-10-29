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
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 260))]
    var body: some View {
        VStack {
            search
        }
        .searchable(text: $viewModel.query, prompt: "Movies, Shows, People")
        .task(id: viewModel.query) {
            await viewModel.search(viewModel.query)
        }
        .navigationDestination(for: ItemContent.self) { item in
			ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
				.ignoresSafeArea(.all, edges: .horizontal)
        }
		.navigationDestination(for: SearchItemContent.self) { item in
			if item.media == .person {
                PersonDetailsView(name: item.itemTitle, id: item.id)
					.ignoresSafeArea(.all, edges: .horizontal)
			} else {
				ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
					.ignoresSafeArea(.all, edges: .horizontal)
			}
		}
		.navigationDestination(for: Person.self) { person in
            PersonDetailsView(name: person.name, id: person.id)
				.ignoresSafeArea(.all, edges: .horizontal)
		}
        .navigationDestination(for: CombinedKeywords.self) { keyword in
            KeywordSectionView(keyword: keyword)
        }
        .ignoresSafeArea(.all, edges: .horizontal)
    }
    
    @ViewBuilder
    private var search: some View {
        switch viewModel.stage {
        case .none: TrendingKeywordsListView()
        case .searching:
            ProgressView("Searching")
                .foregroundColor(.secondary)
                .padding()
        case .empty: ContentUnavailableView("No Results", systemImage: "magnifyingglass")
        case .failure: ContentUnavailableView("Search failed, try again later.", systemImage: "magnifyingglass")
        case .success:
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.items) { item in
                        if item.media == .person {
                            PersonSearchImage(item: item)
                                .padding([.leading, .trailing], 2)
                                .padding(.horizontal, 6)
                                .padding(.vertical)
                        } else {
                            SearchContentPosterView(item: item,
                                                    showPopup: $showPopup,
                                                    popupType: $popupType)
                            .padding([.leading, .trailing], 2)
                            .padding(.horizontal, 6)
                            .padding(.vertical)
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
                .padding(.horizontal)
            }
            .ignoresSafeArea(.all, edges: .horizontal)
        }
    }
}
#endif
