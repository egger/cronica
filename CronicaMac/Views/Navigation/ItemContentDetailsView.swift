//
//  ItemContentDetailsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentDetailsView: View {
    let id: Int
    let title: String
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showConfirmation = false
    @State private var showSeasonConfirmation = false
    private var itemUrl: URL
    init(id: Int, title: String, type: MediaType) {
        self.id = id
        self.title = title
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading")
            }
            VStack {
                ScrollView {
                    WebImage(url: viewModel.content?.cardImageOriginal)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            ZStack {
                                VStack {
                                    Spacer()
                                    ZStack(alignment: .bottom) {
                                        Color.black.opacity(0.4)
                                            .frame(height: 80)
                                            .mask {
                                                LinearGradient(colors: [Color.black,
                                                                        Color.black.opacity(0.924),
                                                                        Color.black.opacity(0.707),
                                                                        Color.black.opacity(0.383),
                                                                        Color.black.opacity(0)],
                                                               startPoint: .bottom,
                                                               endPoint: .top)
                                            }
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                            .frame(height: 140)
                                            .mask {
                                                VStack(spacing: 0) {
                                                    LinearGradient(colors: [Color.black.opacity(0),
                                                                            Color.black.opacity(0.383),
                                                                            Color.black.opacity(0.707),
                                                                            Color.black.opacity(0.924),
                                                                            Color.black],
                                                                   startPoint: .top,
                                                                   endPoint: .bottom)
                                                    .frame(height: 80)
                                                    Rectangle()
                                                }
                                            }
                                    }
                                }
                                VStack {
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        VStack {
                                            Text(title)
                                                .lineLimit(1)
                                                .font(.title)
                                                .foregroundColor(.white)
                                            GlanceInfo(info: viewModel.content?.itemInfo)
                                                .padding(.bottom, 6)
                                                .foregroundColor(.secondary)
                                            WatchlistButtonView()
                                                .environmentObject(viewModel)
                                        }
                                        Spacer()
                                        OverviewBoxView(overview: viewModel.content?.itemOverview,
                                                        title: "About",
                                                        type: .movie)
                                        .foregroundColor(.white)
                                        .padding([.horizontal, .top])
                                        .frame(width: 600)
                                    }
                                    .padding()
                                }
                            }
                        }
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                tvId: id,
                                inWatchlist: $viewModel.isInWatchlist,
                                seasonConfirmation: $showSeasonConfirmation)
                    .padding(0)
                    
                    CastListView(credits: viewModel.credits)
                    
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "list.and.film",
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: true)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    AttributionView()
                }
            }
            .task {
                await viewModel.load()
            }
            .navigationDestination(for: Person.self) { item in
                PersonDetailsView(title: item.name, id: item.id)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
                    }, label: {
                        Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                              systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
                    })
                    .keyboardShortcut("w", modifiers: [.option])
                    .disabled(viewModel.isLoading ? true : false)
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.updateMarkAs(markAsFavorite: !viewModel.isFavorite)
                    }, label: {
                        Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                              systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
                    })
                    .keyboardShortcut("f", modifiers: [.option])
                    .disabled(viewModel.isLoading ? true : false)
                }
                ToolbarItem {
                    ShareLink(item: itemUrl)
                }
            }
            .navigationTitle(title)
        }
    }
}

struct ItemContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentDetailsView(id: ItemContent.previewContent.id,
                               title: ItemContent.previewContent.itemTitle,
                               type: ItemContent.previewContent.itemContentMedia)
    }
}

struct GlanceInfo: View {
    var info: String?
    var body: some View {
        if let info {
            Text(info)
                .font(.callout)
        }
    }
}