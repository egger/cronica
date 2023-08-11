//
//  ItemContentSectionDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI

struct ItemContentSectionDetails: View {
	let title: String
	let items: [ItemContent]
	@State private var showPopup = false
	@State private var popupType: ActionPopupItems?
	@StateObject private var settings = SettingsStore.shared
	@State private var query = String()
	@State private var queryResult = [ItemContent]()
	var body: some View {
		VStack {
#if os(tvOS)
			cardStyle
#else
			switch settings.sectionStyleType {
			case .list: listStyle
			case .card: cardStyle
			case .poster: ScrollView { posterStyle }
			}
#endif
		}
		.navigationTitle(LocalizedStringKey(title))
		.toolbar {
#if os(iOS)
			ToolbarItem(placement: .navigationBarTrailing) {
				styleOptions
			}
#endif
		}
		.actionPopup(isShowing: $showPopup, for: popupType)
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		.searchable(text: $query, placement: UIDevice.isIPhone ? .navigationBarDrawer(displayMode: .always) : .toolbar)
		.autocorrectionDisabled()
		.onChange(of: query) { _ in
			if query.isEmpty && !queryResult.isEmpty {
				withAnimation {
					queryResult.removeAll()
				}
			} else {
				queryResult.removeAll()
				queryResult = items.filter {
					$0.itemTitle.lowercased().contains(query.lowercased())
				}
			}
		}
#endif
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
					if !queryResult.isEmpty {
						ForEach(queryResult) { item in
							ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
						}
					} else {
						ForEach(items) { item in
							ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
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
		ScrollView {
			LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
				if !queryResult.isEmpty {
					ForEach(queryResult) { item in
						ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
							.buttonStyle(.plain)
					}
				} else {
					ForEach(items) { item in
						ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
							.buttonStyle(.plain)
					}
				}
			}
			.padding()
		}
	}
	
#if !os(tvOS)
	private var posterStyle: some View {
#if os(iOS)
		LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
				  spacing: settings.isCompactUI ? 10 : 20) {
			if !queryResult.isEmpty {
				ForEach(queryResult) { item in
					ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
						.buttonStyle(.plain)
				}
			} else {
				ForEach(items) { item in
					ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
						.buttonStyle(.plain)
				}
			}
		}.padding(.all, settings.isCompactUI ? 10 : nil)
#elseif os(macOS)
		LazyVGrid(columns: DrawingConstants.posterColumns, spacing: 20) {
			ForEach(items) { item in
				ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
					.buttonStyle(.plain)
			}
		}
		.padding()
#endif
	}
#endif
}

struct ItemContentSectionDetails_Previews: PreviewProvider {
	static var previews: some View {
		ItemContentSectionDetails(title: "Preview Items",
								  items: ItemContent.examples)
	}
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
	static let columns = [GridItem(.adaptive(minimum: 240))]
#else
	static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
	static let compactColumns: [GridItem] = [GridItem(.adaptive(minimum: 80))]
#if os(macOS)
	static let posterColumns = [GridItem(.adaptive(minimum: 160))]
	static let cardColumns = [GridItem(.adaptive(minimum: 240))]
#endif
}
