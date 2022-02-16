//
//  MovieDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import SwiftUI

struct MovieDetails: View {
    let title: String
    let id: Int
    @StateObject private var viewModel = MoviesDetailsViewModel()
    @State private var showingOverview: Bool = false
    @State private var showBellIcon: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                if let movie = viewModel.movie {
                    DetailsImageView(url: movie.backdropImage, title: movie.title)
                    HStack {
                        if !movie.genres.isEmpty {
                            ForEach((movie.genres?.prefix(3))!) { genre in
                                Text(genre.name ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if !movie.releaseDateString.isEmpty {
                            Text(movie.releaseDateString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    WatchlistButtonView(title: movie.title, id: movie.id, image: movie.backdropImage, status: movie.status ?? "Released", notify: false, type: 0)
                        .onAppear {
                            if movie.release > Date.now {
                                showBellIcon.toggle()
                            }
                        }
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
                    if !movie.credits.isEmpty {
                        PersonListView(credits: movie.credits!)
                    }
                    Divider()
                        .padding([.horizontal, .top])
                    InformationView(movie: movie)
                        .padding(.top)
                    if movie.similar != nil {
                        Divider()
                            .padding([.horizontal, .top])
                        MovieListView(style: StyleType.poster, title: "You may like", movies: movie.similar?.results)
                            .padding(.bottom)
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
            }
        }
        .task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id)
        }
    }
}

//struct MovieDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetails()
//    }
//}
