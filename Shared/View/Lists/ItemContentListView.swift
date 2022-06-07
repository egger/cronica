//
//  ItemContentListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

struct ItemContentListView: View {
    let items: [ItemContent]?
    let title: String
    let subtitle: String
    let image: String
    @Binding var addedItemConfirmation: Bool
    var body: some View {
        if let items {
            if !items.isEmpty {
                TitleView(title: title,
                          subtitle: subtitle,
                          image: image)
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia), label: {
                                PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                    .modifier(ItemContentContextMenu(item: item, showConfirmation: $addedItemConfirmation))
                                    .padding([.leading, .trailing], 4)
                            })
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

//struct ItemContentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemContentListView()
//    }
//}
