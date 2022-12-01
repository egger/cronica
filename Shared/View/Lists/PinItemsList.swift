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
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        if !items.isEmpty {
            VStack {
                TitleView(title: "My Pins",
                          subtitle: "Pinned Items",
                          image: "pin",
                          showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
                            PosterWatchlistItem(item: item)
                                .buttonStyle(.plain)
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

struct PinItemsList_Previews: PreviewProvider {
    static var previews: some View {
        PinItemsList()
    }
}

