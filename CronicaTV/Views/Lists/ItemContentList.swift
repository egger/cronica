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
                HStack {
                    VStack {
                        HStack {
                            Text(NSLocalizedString(title, comment: ""))
                                .font(.callout)
                                .padding([.top, .horizontal])
                            Spacer()
                        }
                        HStack {
                            Text(NSLocalizedString(subtitle, comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                    Spacer()
                    Image(systemName: image)
                        .foregroundColor(.secondary)
                        .padding()
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
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
