//
//  MovieDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct MovieDetailsView: View {
    let movieId: Int
    let movieTitle: String
    @StateObject private var viewModel = MoviesDetailsViewModel()
    @State private var showingOverview: Bool = false
    @State private var isAboutPresented: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                if let movie = viewModel.movie {
                    DetailsImageView(image: movie.backdropImage, placeholderTitle: movie.title)
                    WatchlistButtonView(title: movie.title, id: movie.id, image: movie.backdropImage, status: movie.status ?? "Released", notify: false, type: "Movie")
                    AboutView(overview: movie.overview)
                        .onTapGesture {
                            showingOverview.toggle()
                        }
                        .sheet(isPresented: $showingOverview) {
                            NavigationView {
                                VStack {
                                    Text(movie.overview)
                                        .padding()
                                }
                                .navigationTitle(movie.title)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Done") {
                                            showingOverview.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    Divider()
                        .padding([.horizontal, .top])
                    PersonListView(credits: movie.credits!)
                    Divider()
                        .padding([.horizontal, .top])
                    InformationView(movie: movie)
                        .padding(.top)
                    if movie.similar != nil {
                        Divider()
                            .padding([.horizontal, .top])
                        MovieListView(style: "poster", title: "You may like", movies: movie.similar?.results)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle(movieTitle)
            .task {
                load()
            }
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.loadMovie(id: self.movieId)
        }
    }
}
