//
//  HorizontalListView.swift
//  Story
//
//  Created by Alexandre Madeira on 16/01/22.
//

import SwiftUI

struct HorizontalMovieListView: View {
    let style: String
    let title: String
    let movies: [Movie]
    var body: some View {
        VStack {
            SectionHeaderView(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(movies) { item in
                        NavigationLink(destination: MovieDetailsView(movieID: item.id,
                                                                     movieTitle: item.title)) {
                            switch style {
                            case "poster":
                                PosterView(title: item.title,
                                           url: item.w500PosterImage)
                                    .padding([.leading, .trailing], 4)
                            case "card":
                                CardView(title: item.title,
                                         url: item.backdropImage)
                                    .padding([.leading, .trailing], 4)
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.leading, item.id == self.movies.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.movies.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}

struct HorizontalMovieListView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalMovieListView(style: "card", title: "popular", movies: Movie.previewMovies)
        HorizontalMovieListView(style: "poster", title: "popular", movies: Movie.previewMovies)
            .preferredColorScheme(.dark)
    }
}
