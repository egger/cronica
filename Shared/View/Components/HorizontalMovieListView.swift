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
    let movies: [Movie]?
    var body: some View {
        VStack {
            if !movies.isEmpty {
                SectionHeaderView(title: title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(movies!) { movie in
                            NavigationLink(destination: MovieDetailsView(movieID: movie.id,
                                                                         movieTitle: movie.title)) {
                                switch style {
                                case "poster":
                                    PosterView(title: movie.title, url: movie.w500PosterImage)
                                        .contextMenu {
                                            Button {
                                                
                                            } label: {
                                                Label("Add to watchlist", systemImage: "bell.square")
                                            }
                                        }
                                        .padding([.leading, .trailing], 4)
                                case "card":
                                    CardView(title: movie.title, url: movie.backdropImage)
                                        .contextMenu {
                                            Button {
                                                
                                            } label: {
                                                Label("Add to watchlist", systemImage: "bell.square")
                                            }
                                        }
                                        .padding([.leading, .trailing], 4)
                                default:
                                    EmptyView()
                                }
                            }
                                                                         .padding(.leading, movie.id == self.movies!.first!.id ? 16 : 0)
                                                                         .padding(.trailing, movie.id == self.movies!.last!.id ? 16 : 0)
                                                                         .padding([.top, .bottom])
                        }
                        
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
