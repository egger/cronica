//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

#if os(iOS)
struct SearchView: View { 
	static let tag: Screens? = .search
	@StateObject private var viewModel = SearchViewModel()
	@State private var showPopup = false
	@State private var popupType: ActionPopupItems?
	@State private var scope: SearchItemsScope = .noScope
	@State private var currentlyQuery = String()
	var body: some View {
		ZStack {
			List {
				switch scope {
				case .noScope:
					ForEach(viewModel.items) { item in
						SearchItemView(item: item,
									   showPopup: $showPopup,
									   popupType: $popupType)
					}
					loadableProgressRing
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
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.large)
			.navigationDestination(for: Person.self) { person in
				PersonDetailsView(title: person.name, id: person.id)
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
					PersonDetailsView(title: item.itemTitle, id: item.id)
				} else {
					ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
				}
			}
			.navigationDestination(for: [String:[ItemContent]].self) { item in
				let keys = item.map { (key, _) in key }.first
				let value = item.map { (_, value) in value }.first
				if let keys, let value {
					ItemContentSectionDetails(title: keys, items: value)
				}
			}
			.navigationDestination(for: [Person].self) { items in
				DetailedPeopleList(items: items)
			}
			.navigationDestination(for: CombinedKeywords.self) { keyword in
				KeywordSectionView(keyword: keyword)
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
				if currentlyQuery != viewModel.query {
					currentlyQuery = viewModel.query
					await viewModel.search(viewModel.query)
				}
			}
			.overlay(searchResults)
			.actionPopup(isShowing: $showPopup, for: popupType)
		}
	}
	
	@ViewBuilder
	private var searchResults: some View {
		switch viewModel.stage {
		case .none:
			ScrollView {
				VStack {
					TrendingPeopleListView()
						.environmentObject(viewModel)
					TrendingKeywordsListView()
						.environmentObject(viewModel)
					Spacer()
				}
				.task {
					await viewModel.loadTrendingPeople()
					await viewModel.loadTrendingKeywords()
				}
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
	
	@ViewBuilder
	private var loadableProgressRing: some View {
		if viewModel.startPagination && !viewModel.endPagination {
			CenterHorizontalView {
				ProgressView()
					.padding()
					.onAppear {
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							viewModel.loadMoreItems()
						}
					}
			}
		} else {
			EmptyView()
		}
	}
}
#endif

#if os(iOS)
struct SearchView_Previews: PreviewProvider {
	static var previews: some View {
		SearchView()
	}
}
#endif
