//
//  KeywordSectionView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI

struct KeywordSectionView: View {
	let keyword: CombinedKeywords
    
    // States
	@StateObject private var settings = SettingsStore.shared
	@State private var showPopup = false
	@State private var popupType: ActionPopupItems?
	@State private var sortBy: TMDBSortBy = .popularity
    @State private var page = 1
    @State private var items = [ItemContent]()
    @State private var isLoaded = false
    @State private var startPagination = false
    @State private var endPagination = false
    
    // Network service
    private let network = NetworkService.shared
	var body: some View {
		VStack {
			switch settings.sectionStyleType {
			case .list: listStyle
			case .poster: ScrollView { posterStyle }
			case .card: ScrollView { cardStyle }
			}
		}
		.navigationTitle(NSLocalizedString(keyword.name, comment: ""))
		.overlay { if !isLoaded { ProgressView().unredacted() } }
		.onAppear {
			Task {
				await load(keyword.id, sortBy: sortBy, reload: false)
			}
		}
        .onChange(of: sortBy) { _, newSortBy in
            Task {
                await load(keyword.id, sortBy: sortBy, reload: true)
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
				.disabled(!isLoaded)
			}
#endif
		}
		.redacted(reason: isLoaded ? [] : .placeholder)
	}
	
	private var sortButton: some View {
		Menu {
			Picker(selection: $sortBy) {
				ForEach(TMDBSortBy.allCases) { item in
					Text(item.localizedString).tag(item)
				}
			} label: {
				Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
			}
		} label: {
			Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
		}
	}
	
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
	
	private var listStyle: some View {
		Form {
			Section {
				List {
					ForEach(items) { item in
						ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
					}
					if isLoaded && !endPagination {
						CenterHorizontalView {
							ProgressView("Loading")
								.padding(.horizontal)
								.onAppear {
									DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
										Task {
											await load(keyword.id, sortBy: sortBy, reload: false)
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
			ForEach(items) { item in
				ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
					.buttonStyle(.plain)
			}
			if isLoaded && !endPagination {
				CenterHorizontalView {
					ProgressView()
						.padding()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
								Task {
									await load(keyword.id, sortBy: sortBy, reload: false)
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
			ForEach(items) { item in
				ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
					.buttonStyle(.plain)
			}
			if isLoaded && !endPagination {
				CenterHorizontalView {
					ProgressView()
						.padding()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
								Task {
									await load(keyword.id, sortBy: sortBy, reload: false)
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

extension KeywordSectionView {
    func load(_ id: Int, sortBy: TMDBSortBy, reload: Bool) async {
        do {
            if reload {
                withAnimation {
                    items.removeAll()
                    isLoaded = false
                    page = 1
                }
            }
            let movies = try await network.fetchKeyword(type: .movie,
                                                        page: page,
                                                        keywords: id,
                                                        sortBy: sortBy.rawValue)
            let shows = try await network.fetchKeyword(type: .tvShow,
                                                       page: page,
                                                       keywords: id,
                                                       sortBy: sortBy.rawValue)
            let result = movies + shows
            if result.isEmpty {
                endPagination = true
                return
            } else {
                page += 1
            }
            withAnimation {
                items.append(contentsOf: result.sorted { $0.itemPopularity > $1.itemPopularity })
            }
            if !startPagination { startPagination = true }
            if !isLoaded {
                await MainActor.run {
                    self.isLoaded = true
                }
            }
        } catch {
            if Task.isCancelled { return }
            let message = "Keyword ID: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "KeywordSection.load()")
        }
    }
}
