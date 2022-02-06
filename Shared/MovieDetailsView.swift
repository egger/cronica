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
    @State private var isSharePresented: Bool = false
    var body: some View {
        VStack {
            if let movie = viewModel.movie {
                DetailsBodyView(movie: movie)
            }
        }
        .navigationTitle(movieTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isSharePresented.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $isSharePresented) {
                    
                }
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

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsBodyView(movie: Movie.previewMovie)
    }
}

struct DetailsBodyView: View {
    let movie: Movie
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MovieItem.id, ascending: true)],
        animation: .default)
    private var movieItems: FetchedResults<MovieItem>
    @State private var isAdded: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                DetailsImageView(image: movie.backdropImage,
                                 placeholderTitle: movie.title)
                    .padding(.horizontal)
                VStack {
                    Button {
                        generator.impactOccurred(intensity: 1.0)
                        addItem(title: movie.title, id: movie.id, image: movie.backdropImage, notify: false)
                    } label: {
                        Label("Add to watchlist", systemImage: "plus.square")
                            .padding(.horizontal)
                            .padding([.top, .bottom], 6)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                }
                AboutView(overview: movie.overview)
                Divider()
                    .padding([.horizontal, .top])
                HorizontalCreditsView(cast: movie.credits!.cast, crew: movie.credits!.crew)
                Divider()
                    .padding([.horizontal, .top])
                InformationView(movie: movie)
                    .padding(.top)
            }
        }
    }
    
    private func addItem(title: String, id: Int, image: URL, notify: Bool = false) {
        withAnimation {
            var inWatchlist: Bool = false
            for i in movieItems {
                if i.id == movie.id {
                    inWatchlist = true
                }
            }
            if !inWatchlist {
                let item = MovieItem(context: viewContext)
                item.title = title
                item.id = Int32(id)
                item.image = image
                item.notify = notify
                do {
                    try viewContext.save()
                } catch {
                    fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
                }
            }
            
        }
    }
}
