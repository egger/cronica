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
                            .padding([.top, .bottom], 6)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                        share()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding(.horizontal)
                            .padding([.top, .bottom], 6)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                OverviewBoxView(overview: movie.overview)
                HorizontalCreditsView(cast: movie.credits!.cast)
                Divider()
                    .padding([.horizontal, .top])
                InformationBoxView(movie: movie)
                    .padding(.top)
            }
        }
    }
    
    func share() {
        let shareSheetVC = UIActivityViewController(
            activityItems: [
                movie.title as Any,
                movie.shareLink as Any
            ],
            applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController!.present(shareSheetVC, animated: true)
    }
}
