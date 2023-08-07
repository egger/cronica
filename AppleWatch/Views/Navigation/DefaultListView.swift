//
//  DefaultListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct DefaultListView: View {
    @Binding var selectedOrder: SmartFiltersTypes?
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    var body: some View {
        if let selectedOrder {
            switch selectedOrder {
            case .released:
                List {
                    WatchlistSectionView(items: items.filter { $0.isReleased },
                                         title: "Released")
                }
            case .production:
                List {
                    WatchlistSectionView(items: items.filter { $0.isInProduction || $0.isUpcoming},
                                         title: "In Production")
                }
            case .watched:
                List {
                    WatchlistSectionView(items: items.filter { $0.isWatched },
                                         title: "Watched")
                }
            case .favorites:
                List {
                    WatchlistSectionView(items: items.filter { $0.isFavorite },
                                         title: "Favorites")
                }
            case .pin:
                List {
                    WatchlistSectionView(items: items.filter { $0.isPin },
                                         title: "Pins")
                }
            case .archive:
                List {
                    WatchlistSectionView(items: items.filter { $0.isArchive },
                                         title: "Archive")
                }
            case .watching:
                List {
                    WatchlistSectionView(items: items.filter { $0.isCurrentlyWatching },
                                         title: "Watching")
                }
            case .notWatched:
                List {
                    WatchlistSectionView(items: items.filter { !$0.isCurrentlyWatching && !$0.isWatched },
                                         title: "Watching")
                }
            }
        } else {
            EmptyListView()
        }
    }
}

struct DefaultListView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListView(selectedOrder: .constant(.released))
    }
}
