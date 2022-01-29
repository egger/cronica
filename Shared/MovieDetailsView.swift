//
//  MovieDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct MovieDetailsView: View {
    let movieID: Int
    let movieTitle: String
    @StateObject private var viewModel = MoviesDetailsViewModel()
    var body: some View {
        VStack {
            if let movie = viewModel.movie {
                DetailsBodyView(movie: movie)
            }
        }
        .navigationTitle(movieTitle)
        .task {
            load()
        }
        .overlay(OverlayView(phase: viewModel.phase, retry: load, title: movieTitle))
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.loadMovie(id: self.movieID)
        }
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsBodyView(movie: Movie.previewMovie)
    }
}


struct DetailsBodyView: View {
    let movie: Movie
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var body: some View {
        ScrollView {
            VStack {
                DetailsImageView(image: movie.backdropImage,
                                 placeholderTitle: movie.title)
                HStack {
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                    } label: {
                        Label("Add to watchlist", systemImage: "bell.square")
                            .padding(.horizontal)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding(.horizontal)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                OverviewBoxView(overview: movie.overview)
                Divider()
                    .padding(.horizontal)
                InformationBoxView(movie: movie)
                    .padding(.top)
            }
        }
    }
}
