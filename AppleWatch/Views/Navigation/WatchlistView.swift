//
//  WatchlistView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    @AppStorage("selectedOrder") private var selectedOrder: SmartFiltersTypes = .released
	@AppStorage("defaultWatchlistSortOrder") private var sortOrder: WatchlistSortOrder = .titleAsc
    @State private var selectedList: SmartFiltersTypes?
    @State private var selectedCustomList: CustomList?
    @State private var query = ""
    @State private var showPicker = false
    var body: some View {
        NavigationStack {
            VStack {
                if selectedList != nil {
                    defaultList
                } else if selectedCustomList != nil {
                    customList
                } else {
                    EmptyListView()
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .disableAutocorrection(true)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        filterButton
                        sortButton
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(id: item.itemId,
                                title: item.itemTitle,
                                type: item.itemMedia,
                                image: item.backCompatibleCardImage)
            }
            .navigationDestination(for: ItemContent.self) { item in
				ItemContentView(id: item.id,
								title: item.itemTitle,
								type: item.itemContentMedia,
								image: item.cardImageMedium)
            }
			.navigationDestination(for: SearchItemContent.self) { item in
				if item.media == .person {
					PersonView(id: item.id, name: item.itemTitle)
				} else {
					ItemContentView(id: item.id,
									title: item.itemTitle,
									type: item.itemContentMedia,
									image: item.cardImageMedium)
				}
			}
            .sheet(isPresented: $showPicker) {
                WatchlistSelectorView(showView: $showPicker,
                                      selectedList: $selectedList,
                                      selectedCustomList: $selectedCustomList)
            }
            .onAppear {
                if selectedList == nil && selectedCustomList == nil {
                    selectedList = selectedOrder
                }
            }
            .onChange(of: selectedList) { newValue in
                if let newValue {
                    selectedOrder = newValue
                }
            }
        }
    }
	
	private var sortButton: some View {
		Picker(selection: $sortOrder) {
			ForEach(WatchlistSortOrder.allCases) { item in
				Text(item.localizableName).tag(item)
			}
		} label: {
			Label("Sort Order", systemImage: "arrow.up.arrow.down.circle")
				.labelStyle(.iconOnly)
		}
		.pickerStyle(.navigationLink)
		.buttonBorderShape(.roundedRectangle(radius: 16))
		.buttonStyle(.bordered)
	}
    
    private var filterButton: some View {
        Button {
            withAnimation { showPicker = true }
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease")
                .foregroundColor(.white)
				.labelStyle(.iconOnly)
        }
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    private var defaultList: some View {
        if items.isEmpty {
            EmptyListView()
        } else {
			DefaultListView(selectedOrder: $selectedList, sortOrder: $sortOrder)
        }
    }
    
    @ViewBuilder
    private var customList: some View {
        if items.isEmpty {
            EmptyListView()
        } else {
			CustomListView(list: $selectedCustomList, sortOrder: $sortOrder)
        }
    }
}

#Preview {
    WatchlistView()
}
