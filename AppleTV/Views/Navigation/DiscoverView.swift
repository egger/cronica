//
//  DiscoverView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct DiscoverView: View {
    static let tag: Screens? = .discover
    @State private var showConfirmation = false
    @State private var onChanging = false
    @StateObject private var viewModel: DiscoverViewModel
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 240 ))
    ]
    init() {
        _viewModel = StateObject(wrappedValue: DiscoverViewModel())
    }
    var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.isLoaded {
                    ProgressView()
                        .unredacted()
                }
                ScrollView {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.items) { item in
                                ItemContentCardView(item: item, showConfirmation: $showConfirmation)
                                    .buttonStyle(.plain)
                            }
                            if !viewModel.startPagination || !viewModel.endPagination {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                viewModel.loadMoreItems()
                                            }
                                        }
                                    Spacer()
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
                        if !viewModel.items.isEmpty {
                            AttributionView()
                        }
                    }
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                    }
                    .navigationDestination(for: Person.self) { person in
                        PersonDetailsView(title: person.name, id: person.id)
                    }
                }
                ConfirmationDialogView(showConfirmation: $showConfirmation)
            }
            .navigationTitle("Explore")
            .task {
                await load()
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Picker("Media", selection: $viewModel.selectedMedia) {
                        Text(MediaType.movie.title).tag(MediaType.movie)
                        Text(MediaType.tvShow.title).tag(MediaType.tvShow)
                    }
                    .pickerStyle(.menu)
                }
                ToolbarItem(placement: .automatic) {
                    Picker("Genre", selection: $viewModel.selectedGenre) {
                        if viewModel.selectedMedia == .movie {
                            ForEach(viewModel.movies.sorted { $0.name! < $1.name! }) { genre in
                                Text(genre.name!).tag(genre.id)
                            }
                        } else {
                            ForEach(viewModel.shows.sorted { $0.name! < $1.name! }) { genre in
                                Text(genre.name!).tag(genre.id)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .onChange(of: viewModel.selectedMedia) { value in
                onChanging = true
                var genre: Genre?
                if value == .tvShow {
                    genre = viewModel.shows[0]
                } else {
                    genre = viewModel.movies[0]
                }
                if let genre {
                    viewModel.selectedGenre = genre.id
                }
                Task {
                    await load()
                }
                
            }
            .onChange(of: viewModel.selectedGenre) { value in
                onChanging = true
                Task {
                    await load()
                }
            }
        }
    }
    
    private func load() async {
        if onChanging {
            viewModel.restartFetch = true
            onChanging = false
            viewModel.loadMoreItems()
        } else {
            viewModel.loadMoreItems()
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
