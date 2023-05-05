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

struct HorizontalWatchlistList: View {
    let items: [WatchlistItem]
    let title: String
    let subtitle: String
    var image: String?
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        VStack {
#if os(tvOS)
            TitleView(title: title,
                      subtitle: subtitle)
#else
            NavigationLink(value: [title:items]) {
                TitleView(title: title,
                          subtitle: subtitle,
                          image: image,
                          showChevron: true)
            }
            .buttonStyle(.plain)
#endif
            ScrollView(.horizontal, showsIndicators: false) {
                if settings.listsDisplayType == .card {
                    LazyHStack {
                        ForEach(items) { item in
                            WatchlistItemFrame(content: item)
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .padding(.top, 8)
                                .padding(.bottom)
                                .buttonStyle(.plain)
                        }
                    }
                } else {
                    LazyHStack {
                        ForEach(items) { item in
                            WatchlistItemPoster(content: item)
                                .padding([.leading, .trailing], settings.isCompactUI ? 1 : 4)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .padding(.top, 8)
                                .padding(.bottom)
                        }
                    }
#if os(tvOS)
                    .padding(.vertical)
                    .padding(.horizontal)
#endif
                }
            }
        }
    }
}
