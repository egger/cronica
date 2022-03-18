//
//  FilmographyListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import SwiftUI

struct FilmographyListView: View {
    let filmography: [Filmography]
    var body: some View {
        VStack {
            HStack {
                Text("Filmography")
                    .font(.headline)
                    .padding([.top, .horizontal])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(filmography.prefix(10)) { item in
                        NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                       id: item.id,
                                                                       type: item.media)) {
                            PosterView(title: item.itemTitle, url: item.image)
                                .padding([.leading, .trailing], 4)
                        }
                        .padding(.leading, item.id == self.filmography.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.filmography.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}
