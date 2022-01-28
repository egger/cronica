//
//  MovieDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct MovieDetailsView: View {
    let movie: Movie
    var body: some View {
        ScrollView {
            LazyVStack {
                MovieImageView(image: movie.backdropImage,
                               placeholderTitle: movie.title)
                HStack {
                    Button {
                        print("Watchlist button!")
                    } label: {
                        Label("Add to watchlist", systemImage: "bell.square")
                            .padding()
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    Button {
                        print("Share button!")
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding()
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                OverviewBoxView(overview: movie.overview!)
                //HorizontalCastView(cast: movie.credits!.cast)
                //InformationBoxView(movie: movie)
            }
            .navigationTitle(movie.title)
            .task {
                
            }
        }
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movie: Movie.previewMovie)
        MovieDetailsView(movie: Movie.previewMovie)
            .preferredColorScheme(.dark)
    }
}
