//
//  DetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct DetailsView: View {
    let id: Int
    let title: String
    @StateObject private var viewModel = MoviesDetailsViewModel()
    var body: some View {
        VStack {
            if let movie = viewModel.movie {
                DetailsBodyView(movie: movie)
            } else {
                Text("hum?")
            }
        }
        .navigationTitle(title)
        .task {
            loadMovie()
        }
        .overlay(OverlayView(phase: viewModel.phase, retry: loadMovie, title: title))
        
    }
    
    @Sendable
    private func loadMovie() {
        Task { await self.viewModel.loadMovie(id: self.id) }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(id: Movie.previewMovie.id, title: Movie.previewMovie.title)
        DetailsView(id: Movie.previewMovie.id, title: Movie.previewMovie.title)
            .preferredColorScheme(.dark)
    }
}

struct DetailsBodyView: View {
    let movie: Movie
    var body: some View {
        ScrollView {
            VStack {
                DetailsImageView(image: movie.backdropImage,
                                 placeholderTitle: movie.title)
                HStack {
                    Button {
                        print("Watchlist button!")
                    } label: {
                        Label("Add to watchlist", systemImage: "bell.square")
                            .padding(.horizontal)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    Button {
                        print("Share button!")
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding(.horizontal)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                OverviewBoxView(overview: movie.overview)
            }
        }
    }
}
