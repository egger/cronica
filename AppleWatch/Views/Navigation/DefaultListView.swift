//
//  DefaultListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct DefaultListView: View {
    @Binding var selectedOrder: SmartFiltersTypes?
	@Binding var sortOrder: WatchlistSortOrder
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
	private var sortedItems: [WatchlistItem] {
		switch sortOrder {
		case .titleAsc:
			return items.sorted { $0.itemTitle < $1.itemTitle }
		case .titleDesc:
			return items.sorted { $0.itemTitle > $1.itemTitle }
		case .ratingAsc:
			return items.sorted { $0.userRating < $1.userRating }
		case .ratingDesc:
			return items.sorted { $0.userRating > $1.userRating }
		case .dateAsc:
			return items.sorted { $0.itemSortDate < $1.itemSortDate }
		case .dateDesc:
			return items.sorted { $0.itemSortDate > $1.itemSortDate }
		}
	}
	private var smartFiltersItems: [WatchlistItem] {
		switch selectedOrder {
		case .released:
			return sortedItems.filter { $0.isReleased }
		case .production:
			return sortedItems.filter { $0.isInProduction || $0.isUpcoming }
		case .watching:
			return sortedItems.filter { $0.isCurrentlyWatching }
		case .watched:
			return sortedItems.filter { $0.isWatched }
		case .favorites:
			return sortedItems.filter { $0.isFavorite }
		case .pin:
			return sortedItems.filter { $0.isPin }
		case .archive:
			return sortedItems.filter { $0.isArchive }
		case .notWatched:
			return sortedItems.filter { !$0.isCurrentlyWatching && !$0.isWatched && $0.isReleased }
		case .none:
			return sortedItems.filter { $0.isReleased }
		}
	}
    var body: some View {
        if let selectedOrder {
			List {
				WatchlistSectionView(items: smartFiltersItems,
									 title: selectedOrder.title)
			}
        } else {
            EmptyListView()
        }
    }
}

struct DefaultListView_Previews: PreviewProvider {
    static var previews: some View {
		DefaultListView(selectedOrder: .constant(.released), sortOrder: .constant(.titleAsc))
    }
}
