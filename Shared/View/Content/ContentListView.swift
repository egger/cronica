//
//  ContentListView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ContentListView: View {
    let style: StyleType
    let type: MediaType
    let title: String
    let items: [Content]
    var body: some View {
        VStack {
            if !items.isEmpty {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.headline)
                        .padding([.horizontal, .top])
                    Spacer()
                }
                HStack {
                    Text(NSLocalizedString(type.title, comment: ""))
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.horizontal)
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: type)) {
                                switch style {
                                case .poster:
                                    PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                        .padding([.leading, .trailing], 4)
                                case .card:
                                    CardView(title: item.itemTitle, url: item.cardImageMedium)
                                        .padding([.leading, .trailing], 4)
                                }
                            }
                            .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct ContentListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentListView(style: StyleType.poster,
                        type: MediaType.movie,
                        title: "Popular",
                        items: Content.previewContents)
    }
}
