//
//  DefaultWatchlistViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/03/23.
//

import SwiftUI
import CoreData

class DefaultWatchlistViewModel: ObservableObject {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) var items: FetchedResults<WatchlistItem>
    @Published var filteredItems = [WatchlistItem]()
    @Published var isLoading = false
    @AppStorage("defaultWatchlistShowAllItems") var showAllItems = false
    @AppStorage("selectedSortBy") var selectedSortBy: StandardFilters = .titleAsc
    @AppStorage("selectedOrder") var selectedOrder: DefaultListTypes = .released
    
    func filter() {
        isLoading.toggle()
        if showAllItems {
            filteredItems = []
            filteredItems.append(contentsOf: items)
        } else {
            if !filteredItems.isEmpty {
                filteredItems = []
            }
            switch selectedOrder {
            case .released:
                filteredItems.append(contentsOf: items.filter { $0.isReleased })
            case .upcoming:
                filteredItems.append(contentsOf: items.filter { $0.isUpcoming })
            case .production:
                filteredItems.append(contentsOf: items.filter { $0.isInProduction })
            case .watched:
                filteredItems.append(contentsOf: items.filter { $0.isWatched })
            case .favorites:
                filteredItems.append(contentsOf: items.filter { $0.isFavorite })
            case .pin:
                filteredItems.append(contentsOf: items.filter { $0.isPin })
            case .archive:
                filteredItems.append(contentsOf: items.filter { $0.isArchive })
            }
        }
        switch selectedSortBy {
        case .releaseDateAsc:
            filteredItems.sort { $0.itemDate ?? Date.distantPast < $1.itemDate ?? Date.distantPast }
        case .releaseDateDsc:
            filteredItems.sort { $0.itemDate ?? Date.distantPast > $1.itemDate ?? Date.distantPast }
        case .titleAsc:
            filteredItems.sort { $0.itemTitle < $1.itemTitle }
        case .titleDsc:
            filteredItems.sort { $0.itemTitle > $1.itemTitle }
        case .lastModified:
            filteredItems.sort { $0.lastValuesUpdated ?? Date() < $1.lastValuesUpdated ?? Date() }
        }
        isLoading = false
    }
}
