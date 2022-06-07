//
//  TrendingListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct TrendingListView: View {
    let items: [ItemContent]?
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    @Binding var showConfirmation: Bool
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
                                    .modifier(ItemContentContext(shareItems: $shareItems, item: item, isSharePresented: $isSharePresented, showConfirmation: $showConfirmation))
                                    .padding([.leading, .trailing], 4)
                                    .sheet(isPresented: $isSharePresented,
                                           content: { ActivityViewController(itemsToShare: $shareItems) })
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
    @State private static var showConfirmation: Bool = false
    static var previews: some View {
        TrendingListView(items: ItemContent.previewContents,
                         showConfirmation: $showConfirmation)
    }
}
