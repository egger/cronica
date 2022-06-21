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
    var body: some View {
        if let items {
            if !items.isEmpty {
                VStack {
                    TitleView(title: title,
                              subtitle: subtitle,
                              image: image)
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack {
                            ForEach(items) { item in
                                NavigationLink(value: item) {
                                    PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                        .frame(width: DrawingConstants.posterWidth,
                                               height: DrawingConstants.posterHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                                    style: .continuous))
                                        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                                                radius: DrawingConstants.shadowRadius)
                                        .modifier(ItemContentContextMenu(item: item,
                                                                         showConfirmation: $addedItemConfirmation))
                                        .padding([.leading, .trailing], 4)
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                            }
                        }
                    })
                }
                
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

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 2.5
}
