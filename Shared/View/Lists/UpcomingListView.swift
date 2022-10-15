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
                TitleView(title: "Upcoming",
                          subtitle: "From Watchlist",
                          image: "rectangle.stack")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
                            CardView(item: item)
                                .buttonStyle(.plain)
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

struct UpcomingListView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingListView(items: [WatchlistItem.example])
    }
}
