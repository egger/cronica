//
//  WatchlistItemListView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 29/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVWatchlistItemListView: View {
    let items: [WatchlistItem]
    let title: String
    let subtitle: String
    let image: String
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                TitleView(title: title, subtitle: subtitle, image: image)
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(items) { item in
                            WatchlistItemFrame(content: item)
                                .padding([.leading, .trailing], 4)
                                .buttonStyle(.plain)
                                .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct WatchlistItemListView_Previews: PreviewProvider {
    static var previews: some View {
        TVWatchlistItemListView(items: [WatchlistItem.example], title: "Items", subtitle: "Preview", image: "film")
    }
}
#endif
