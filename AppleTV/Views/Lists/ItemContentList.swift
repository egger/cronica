//
//  ItemContentList.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct ItemContentList: View {
    let items: [ItemContent]
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
                            ItemContentCardView(item: item)
                                .padding([.leading, .trailing], 4)
                                .buttonStyle(.plain)
                                .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                        }
                    }
                }
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .padding()
        }
    }
}

struct ItemContentList_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentList(items: [ItemContent.previewContent],
                        title: "Preview",
                        subtitle: "Preview Sample",
                        image: "film")
    }
}
