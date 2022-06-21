//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct DiscoverView: View {
    static let tag: Screens? = .explore
    @State private var showConfirmation: Bool = false
    @State private var selectedMedia: MediaType = .movie
    @State private var selectedGenre: Int = 28
    @State private var isLoading: Bool = true
    @State private var onChanging: Bool = false
    @StateObject private var viewModel: DiscoverViewModel
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))
    ]
    init() {
        _viewModel = StateObject(wrappedValue: DiscoverViewModel(id: 28, type: .movie))
    }
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        if let content = viewModel.items {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(content) { item in
                                    ItemContentFrameView(item: item, showConfirmation: $showConfirmation)
                                        .buttonStyle(.plain)
                                }
                                if viewModel.startPagination || !viewModel.endPagination {
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                viewModel.loadMoreItems()
                                            }
                                        }
                                }
                            }
                            .padding()
                            if viewModel.endPagination {
                                HStack {
                                    Spacer()
                                    Text("This is the end.")
                                        .padding()
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            AttributionView()
                        } else {
                            ProgressView()
                        }
                    }
                }
                ConfirmationDialogView(showConfirmation: $showConfirmation)
            }
            .navigationTitle("Explore")
            .task {
                load()
            }
            .redacted(reason: isLoading ? .placeholder : [] )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Media", selection: $selectedMedia) {
                        Text(MediaType.movie.title).tag(MediaType.movie)
                        Text(MediaType.tvShow.title).tag(MediaType.tvShow)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Genre", selection: $selectedGenre) {
                        if selectedMedia == .movie {
                            ForEach(viewModel.movies.sorted { $0.name! < $1.name! }) { genre in
                                Text(genre.name!).tag(genre.id)
                            }
                        } else {
                            ForEach(viewModel.tvShows.sorted { $0.name! < $1.name! }) { genre in
                                Text(genre.name!).tag(genre.id)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: ItemContent.self) { item in
                ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                CastDetailsView(title: person.name, id: person.id)
            }
            .onChange(of: selectedMedia) { value in
                onChanging = true
                var genre: Genre?
                if value == .tvShow {
                    genre = viewModel.tvShows[0]
                } else {
                    genre = viewModel.movies[0]
                }
                if let genre {
                    selectedGenre = genre.id
                }
                load()
            }
            .onChange(of: selectedGenre) { value in
                onChanging = true
                load()
            }
        }
    }
    
    @Sendable
    private func load() {
        Task {
            if onChanging {
                viewModel.restartFetch = true
                withAnimation {
                    isLoading = true
                }
                onChanging = false
                viewModel.loadMoreItems(genre: selectedGenre, media: selectedMedia)
            } else {
                viewModel.loadMoreItems()
            }
            if viewModel.currentPage == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
    }
}
