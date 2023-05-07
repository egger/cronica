//
//  PinItemsList.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 03/11/22.
//

import SwiftUI

struct PinItemsList: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSPredicate(format: "isPin == %d", true)
    ) var items: FetchedResults<WatchlistItem>
    var body: some View {
        if !items.isEmpty {
            HorizontalWatchlistList(items: items.sorted { $0.itemTitle > $1.itemTitle },
                                    title: "My Pins",
                                    subtitle: "Pinned Items")
        }
    }
}

struct PinItemsList_Previews: PreviewProvider {
    static var previews: some View {
        PinItemsList()
    }
}
