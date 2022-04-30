//
//  TrendingListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct TrendingListView: View {
    let items: [Content]?
    var body: some View {
        if let items = items {
            VStack {
                TitleView(title: "Trending", subtitle: "This week", image: "crown")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                           id: item.id,
                                                                           type: item.itemContentMedia)) {
                                PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                    .padding([.leading, .trailing], 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, item.id == items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingListView(items: Content.previewContents)
    }
}
