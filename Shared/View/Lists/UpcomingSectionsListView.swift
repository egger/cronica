//
//  UpcomingSectionsListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 27/08/22.
//

import SwiftUI

struct UpcomingSectionsList: View {
    var items: FetchedResults<WatchlistItem>
    let title: String
    var body: some View {
        VStack {
            if !items.filter({$0.itemImage != nil}).isEmpty {
                TitleView(title: title,
                          subtitle: "From Watchlist",
                          image: "rectangle.stack")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
                            if item.image != nil {
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
}
