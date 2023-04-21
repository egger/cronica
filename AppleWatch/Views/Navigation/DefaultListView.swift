//
//  DefaultListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct DefaultListView: View {
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    var body: some View {
        List {
            switch selectedOrder {
            case .released:
                WatchlistSectionView(items: items.filter { $0.isReleased },
                                     title: "Released")
            case .upcoming:
                WatchlistSectionView(items: items.filter { $0.isUpcoming },
                                     title: "Upcoming")
            case .production:
                WatchlistSectionView(items: items.filter { $0.isInProduction },
                                     title: "In Production")
            case .watched:
                WatchlistSectionView(items: items.filter { $0.isWatched },
                                     title: "Watched")
            case .favorites:
                WatchlistSectionView(items: items.filter { $0.isFavorite },
                                     title: "Favorites")
            case .pin:
                WatchlistSectionView(items: items.filter { $0.isPin },
                                     title: "Pins")
            case .archive:
                WatchlistSectionView(items: items.filter { $0.isArchive },
                                     title: "Archive")
            }
        }
    }
}

struct DefaultListView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListView()
    }
}
