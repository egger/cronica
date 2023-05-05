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
    var image: String?
    @Binding var addedItemConfirmation: Bool
    var displayAsCard = false
    var endpoint: Endpoints?
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        if let items {
            if !items.isEmpty {
                if displayAsCard {
                    Divider().padding(.horizontal)
                }
                VStack {
#if os(tvOS)
                    TitleView(title: title, subtitle: subtitle)
#else
                    if let endpoint {
                        NavigationLink(value: endpoint) {
                            TitleView(title: title, subtitle: subtitle, image: image, showChevron: true)
                        }
                        .buttonStyle(.plain)
                    } else {
                        NavigationLink(value: [title: items]) {
                            TitleView(title: title, subtitle: subtitle, image: image, showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
#endif
                    ScrollView(.horizontal, showsIndicators: false) {
                        switch settings.listsDisplayType {
                        case .standard:
                            LazyHStack {
                                if displayAsCard {
                                    cardStyle
                                } else {
                                    posterStyle
                                }
                            }
#if os(tvOS)
                    .padding()
#endif
                        case .card: cardStyle
                        case .poster: posterStyle
                        }
                    }
                }
                if displayAsCard { Divider().padding(.horizontal) }
            }
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        if let items {
            LazyHStack {
                ForEach(items) { item in
                    CardFrame(item: item, showConfirmation: $addedItemConfirmation)
                        .padding([.leading, .trailing], 4)
                        .buttonStyle(.plain)
                        .padding(.leading, item.id == items.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                        .padding(.top, 8)
                        .padding(.bottom)
                }
            }
        }
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        if let items {
            LazyHStack {
                ForEach(items) { item in
                    Poster(item: item,
                           addedItemConfirmation: $addedItemConfirmation)
                    .padding([.leading, .trailing], settings.isCompactUI ? 1 : 4)
                    .padding(.leading, item.id == items.first!.id ? 16 : 0)
                    .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                    .padding(.top, settings.isCompactUI ? 4 : 8)
                    .padding(.bottom, settings.isCompactUI ? 4 : nil)
                }
            }
        }
    }
}

struct ItemContentListView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        ItemContentListView(items: ItemContent.examples,
                            title: "Favorites",
                            subtitle: "Favorites Movies",
                            image: "heart",
                            addedItemConfirmation: $show)
    }
}

