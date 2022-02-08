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
        #if os(iOS)
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
        #endif
        .task {
            load()
        }
        //.overlay(OverlayView(phase: viewModel.phase, retry: load, title: movieTitle))
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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MovieItem.id, ascending: true)],
        animation: .default)
    private var movieItems: FetchedResults<MovieItem>
    @State private var isAdded: Bool = false
    #if os(iOS)
    let generator = UIImpactFeedbackGenerator(style: .medium)
    #endif
    var body: some View {
        ScrollView {
            VStack {
                DetailsImageView(image: movie.backdropImage,
                                 placeholderTitle: movie.title)
                    .padding(.horizontal)
                VStack {
                    Button {
                        #if os(iOS)
                        generator.impactOccurred(intensity: 1.0)
                        #endif
                        if !isAdded {
                            withAnimation(.easeInOut) {
                                isAdded.toggle()
                            }
                            addItem(title: movie.title, id: movie.id, image: movie.backdropImage, status: movie.status ?? "" ,notify: false)
                            
                        } else {
                            withAnimation(.easeInOut) {
                                isAdded.toggle()
                            }
                            
                        }
                        
                    } label: {
                        withAnimation(.easeInOut) {
                            Label(!isAdded ? "Add to watchlist" : "Remove from watchlist", systemImage: !isAdded ? "plus.square" : "minus.square")
                                .padding(.horizontal)
                                .padding([.top, .bottom], 6)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(isAdded ? .red : .blue)
                }
                AboutView(overview: movie.overview)
                Divider()
                    .padding([.horizontal, .top])
                HorizontalCreditsView(cast: movie.credits!.cast, crew: movie.credits!.crew)
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
            .onAppear {
                for item in movieItems {
                    if item.id == movie.id {
                        isAdded.toggle()
                    }
                }
            }
        }
    }
    
    private func addItem(title: String, id: Int, image: URL, status: String, notify: Bool = false) {
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
                item.status = status
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
