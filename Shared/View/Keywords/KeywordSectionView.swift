//
//  KeywordSectionView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI

struct KeywordSectionView: View {
	let keyword: CombinedKeywords
	@StateObject private var viewModel = KeywordSectionViewModel()
	@StateObject private var settings = SettingsStore.shared
	@State private var showPopup = false
	@State private var popupType: ActionPopupItems?
	@State private var sortBy: KeywordsSearchSortBy = .popularity
	var body: some View {
		VStack {
			switch settings.sectionStyleType {
			case .list: listStyle
			case .poster: ScrollView { posterStyle }
			case .card: ScrollView { cardStyle }
			}
		}
		.navigationTitle(NSLocalizedString(keyword.name, comment: ""))
		.overlay { if !viewModel.isLoaded { ProgressView().unredacted() } }
		.onAppear {
			Task {
				await viewModel.load(keyword.id, sortBy: sortBy, reload: false)
			}
		}
		.onChange(of: sortBy) { newSortBy in
			Task {
				await viewModel.load(keyword.id, sortBy: sortBy, reload: true)
			}
		}
		.toolbar {
#if os(iOS)
			ToolbarItem(placement: .navigationBarTrailing) {
				HStack {
					sortButton
					styleOptions
				}
				.unredacted()
				.disabled(!viewModel.isLoaded)
			}
#endif
		}
		.redacted(reason: viewModel.isLoaded ? [] : .placeholder)
	}
	
	private var sortButton: some View {
		Menu {
			Picker(selection: $sortBy) {
				ForEach(KeywordsSearchSortBy.allCases) { item in
					Text(item.localizedString).tag(item)
				}
			} label: {
				Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
			}
		} label: {
			Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
		}
	}
	
#if os(iOS) || os(macOS)
	private var styleOptions: some View {
		Menu {
			Picker(selection: $settings.sectionStyleType) {
				ForEach(SectionDetailsPreferredStyle.allCases) { item in
					Text(item.title).tag(item)
				}
			} label: {
				Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
			}
		} label: {
			Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
				.labelStyle(.iconOnly)
		}
	}
#endif
	
	private var listStyle: some View {
		Form {
			Section {
				List {
					ForEach(viewModel.items) { item in
						ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
					}
					if viewModel.isLoaded && !viewModel.endPagination {
						CenterHorizontalView {
							ProgressView("Loading")
								.padding(.horizontal)
								.onAppear {
									DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
										Task {
											await viewModel.load(keyword.id, sortBy: sortBy, reload: false)
										}
									}
								}
						}
					}
				}
			}
		}
#if os(macOS)
		.formStyle(.grouped)
#endif
	}
	
	private var cardStyle: some View {
		LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
			ForEach(viewModel.items) { item in
				ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
					.buttonStyle(.plain)
			}
			if viewModel.isLoaded && !viewModel.endPagination {
				CenterHorizontalView {
					ProgressView()
						.padding()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
								Task {
									await viewModel.load(keyword.id, sortBy: sortBy, reload: false)
								}
							}
						}
				}
			}
		}
		.padding()
	}
	
	@ViewBuilder
	private var posterStyle: some View {
		LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.posterColumns,
				  spacing: settings.isCompactUI ? 10 : 20) {
			ForEach(viewModel.items) { item in
				ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
					.buttonStyle(.plain)
			}
			if viewModel.isLoaded && !viewModel.endPagination {
				CenterHorizontalView {
					ProgressView()
						.padding()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
								Task {
									await viewModel.load(keyword.id, sortBy: sortBy, reload: false)
								}
							}
						}
				}
			}
		}
				  .padding(.all, settings.isCompactUI ? 10 : nil)
	}
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
	static let columns: [GridItem] = [GridItem(.adaptive(minimum: 240))]
#else
	static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
	static let compactColumns: [GridItem] = [GridItem(.adaptive(minimum: 80))]
	static let posterColumns = [GridItem(.adaptive(minimum: 160))]
}
