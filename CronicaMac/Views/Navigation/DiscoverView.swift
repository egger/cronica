//
//  DiscoverView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

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

struct ItemContentCardView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = PersistenceController.shared
    @State private var isInWatchlist: Bool = false
    @State private var isWatched = false
    var body: some View {
        NavigationLink(value: item) {
            VStack {
                WebImage(url: item.cardImageMedium)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.thickMaterial)
                            VStack {
                                Text(item.itemTitle)
                                    .font(.callout)
                                    .lineLimit(DrawingConstants.titleLineLimit)
                                    .padding(.bottom)
                                Image(systemName: "film")
                            }
                            .padding()
                            .foregroundColor(.secondary)
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    }
                    .overlay {
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    if isWatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    } else {
                                        Image(systemName: "square.stack.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    }
                                }
                                .background {
                                    Color.black.opacity(0.5)
                                        .mask {
                                            LinearGradient(colors:
                                                            [Color.black,
                                                             Color.black.opacity(0.924),
                                                             Color.black.opacity(0.707),
                                                             Color.black.opacity(0.383),
                                                             Color.black.opacity(0)],
                                                           startPoint: .bottom,
                                                           endPoint: .top)
                                        }
                                }
                            }
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height:DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.imageShadow)
                    .draggable(item)
                    .modifier(
                        ItemContentContextMenu(item: item,
                                               showConfirmation: $showConfirmation,
                                               isInWatchlist: $isInWatchlist,
                                               isWatched: $isWatched)
                    )
                HStack {
                    Text(item.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                    Spacer()
                }
                .frame(width: DrawingConstants.imageWidth)
            }
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                    if isInWatchlist && !isWatched {
                        isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                    }
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let titleLineLimit: Int = 1
}
