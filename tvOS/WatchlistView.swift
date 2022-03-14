//
//  WatchlistView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct WatchlistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    var body: some View {
        List {
            WatchlistSectionView(items: items.filter { $0.status == "In Production"
                || $0.status == "Post Production"
                || $0.status == "Planned" },
                                 title: "Coming Soon")
            WatchlistSectionView(items: items.filter { $0.status == "Returning Series"},
                                 title: "Releasing")
            WatchlistSectionView(items: items.filter { $0.status == "Released" || $0.status == "Ended"},
                                 title: "Released")
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
