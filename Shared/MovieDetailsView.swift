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
        }        .overlay(OverlayView(phase: viewModel.phase, retry: load, title: movieTitle))
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
        DetailsBodyView(movie: Movie.previewMovie)
            .preferredColorScheme(.dark)
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
                    .padding(.horizontal)
                HStack {
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                    } label: {
                        Label("Add to watchlist", systemImage: "bell.square")
                            .padding(.horizontal)
                            .padding([.top, .bottom], 6)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding(.horizontal)
                            .padding([.top, .bottom], 6)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                OverviewBoxView(overview: movie.overview)
                Divider()
                    .padding([.horizontal, .top])
                HorizontalCreditsView(cast: movie.credits!.cast, crew: movie.credits!.crew)
                Divider()
                    .padding([.horizontal, .top])
                InformationBoxView(movie: movie)
                    .padding(.top)
            }
        }
    }
}
