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
                                    subtitle: "Pinned Items",
                                    image: "pin")
        }
    }
}

struct PinItemsList_Previews: PreviewProvider {
    static var previews: some View {
        PinItemsList()
    }
}

private struct HorizontalWatchlistList: View {
    let items: [WatchlistItem]
    let title: String
    let subtitle: String
    let image: String
    var body: some View {
        VStack {
            NavigationLink(value: [title:items]) {
                TitleView(title: title,
                          subtitle: subtitle,
                          image: image,
                          showChevron: true)
            }
            .buttonStyle(.plain)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(items) { item in
                        PosterWatchlistItem(item: item)
                            .padding([.leading, .trailing], 4)
                            .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                            .padding(.top, 8)
                            .padding(.bottom)
                    }
                }
            }
        }
    }
}
