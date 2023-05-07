//
//  UpcomingListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/10/22.
//

import SwiftUI

struct UpcomingListView: View {
    var items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            VStack {
#if os(tvOS)
                TitleView(title: "Upcoming",
                          subtitle: "From Watchlist")
#else
                NavigationLink(value: items) {
                    TitleView(title: "Upcoming",
                              subtitle: "From Watchlist",
                              showChevron: true)
                }
                .buttonStyle(.plain)
#endif
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
#if os(tvOS)
                            WatchlistItemFrame(content: item)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .buttonStyle(.plain)
#else
                            
                            CardView(item: item)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .buttonStyle(.plain)
#endif
                        }
                    }
                    .padding(.bottom)
                    .padding(.top, 8)
#if os(tvOS)
                    .padding()
#endif
                }
            }
        }
    }
}

struct UpcomingListView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingListView(items: [WatchlistItem.example])
    }
}
