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

//struct MovieDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailsView()
//    }
//}
