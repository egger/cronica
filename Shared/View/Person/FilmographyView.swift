//
//  FilmographyView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct FilmographyView: View {
    let items: [Filmography]
    var body: some View {
        VStack {
            TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(items) { item in
                        NavigationLink(destination: DetailsView(title: item.itemTitle,
                                                                id: item.id,
                                                                type: item.itemMedia)) {
                            PosterView(title: item.itemTitle, url: item.itemImage)
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
