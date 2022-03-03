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
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filmography.prefix(10)) { item in
                        NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                       id: item.id,
                                                                       type: MediaType.movie)) {
                            PosterView(title: item.title ?? "", url: item.image)
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

//struct CreditsList_Previews: PreviewProvider {
//    static var previews: some View {
//        FilmographyListView()
//    }
//}
