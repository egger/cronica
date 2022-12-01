//
//  ItemContentListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

/// Display a list of ItemContent within PosterView, with a TitleView indicating
/// its origin.
struct ItemContentListView: View {
    let items: [ItemContent]?
    let title: String
    let subtitle: String
    let image: String
    @Binding var addedItemConfirmation: Bool
    var displayAsCard = false
    var endpoint: Endpoints?
    var showChevron = false
    var body: some View {
        if let items {
            if !items.isEmpty {
                if displayAsCard {
                    Divider().padding(.horizontal)
                }
                VStack {
                    if let endpoint {
                        NavigationLink(value: endpoint) {
                            TitleView(title: title, subtitle: subtitle, image: image, showChevron: showChevron)
                        }
                        .buttonStyle(.plain)
                    } else {
                        if showChevron {
                            NavigationLink(value: items) {
                                TitleView(title: title, subtitle: subtitle, image: image, showChevron: true)
                            }
                            .buttonStyle(.plain)
                        } else {
                            TitleView(title: title, subtitle: subtitle, image: image)
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        LazyHStack {
                            if displayAsCard {
                                ForEach(items) { item in
#if os(iOS)
                                    CardFrame(item: item,
                                              showConfirmation: $addedItemConfirmation)
                                    .padding([.leading, .trailing], 4)
                                    .buttonStyle(.plain)
                                    .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                    .padding([.top, .bottom])
#else
                                    ItemContentCardView(item: item, showConfirmation: $addedItemConfirmation)
                                        .padding([.leading, .trailing], 4)
                                        .buttonStyle(.plain)
                                        .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                        .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                        .padding([.top, .bottom])
#endif
                                }
                            } else {
                                ForEach(items) { item in
                                    Poster(item: item,
                                           addedItemConfirmation: $addedItemConfirmation)
                                    .padding([.leading, .trailing], 4)
                                    .buttonStyle(.plain)
                                    .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                    .padding([.top, .bottom])
                                }
                            }
                        }
                    })
                }
                if displayAsCard { Divider().padding(.horizontal) }
            }
        }
    }
}

struct ItemContentListView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        ItemContentListView(items: ItemContent.previewContents,
                            title: "Favorites",
                            subtitle: "Favorites Movies",
                            image: "heart",
                            addedItemConfirmation: $show)
    }
}
