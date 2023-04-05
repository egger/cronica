//
//  ItemContentDetails.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

#if os(tvOS)
struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showOverview = false
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ZStack {
            ScrollView {
                header
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                VStack {
                    ScrollView {
                        TVSeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                       id: self.id, inWatchlist: $viewModel.isInWatchlist)
                        TVItemContentList(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "film.stack")
                        TVCastListView(credits: viewModel.credits)
                        TVInfoSection(item: viewModel.content)
                            .padding([.top, .bottom])
                        AttributionView()
                    }
                }
                .task { await viewModel.load() }
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
            }
            .ignoresSafeArea()
            .background {
                TranslucentBackground(image: viewModel.content?.cardImageLarge)
            }
        }
    }
    
    private var header: some View {
        ZStack {
            if viewModel.isLoading { ProgressView("Loading").unredacted() }
            WebImage(url: viewModel.content?.cardImageOriginal)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 1920, height: 1080)
            VStack {
                HStack {
                    Text(title)
                        .font(.title)
                        .lineLimit(1)
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 100)
                Spacer()
                ZStack {
                    Color.black.opacity(0.4)
                        .frame(height: 400)
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
                        .fill(.regularMaterial)
                        .frame(height: 600)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 400)
                                Rectangle()
                            }
                        }
                }
            }
            .padding(.zero)
            .ignoresSafeArea()
            .frame(width: 1920, height: 1080)
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .center) {
                    VStack {
                        VStack {
                            Button {
                                if let item = viewModel.content {
                                    viewModel.updateWatchlist(with: item)
                                }
                            } label: {
                                Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                                      systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
                                .padding([.top, .bottom])
                                .frame(minWidth: 500)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(width: 500)
                            Button {
                                viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
                            } label: {
                                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
                                    .padding([.top, .bottom])
                                    .frame(minWidth: 500)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(width: 500)
                        }
                        .padding()
                    }
                    .padding(.leading)
                    Spacer()
                    VStack {
                        if let overview = viewModel.content?.itemOverview {
                            Button {
                                showOverview.toggle()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(overview)
                                        .lineLimit(4)
                                        .font(.callout)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .sheet(isPresented: $showOverview, content: {
                        ScrollView {
                            if let overview = viewModel.content?.itemOverview {
                                ScrollView {
                                    Text(overview)
                                }
                            }
                        }
                    })
                    .padding()
                    .frame(maxWidth: 900)
                    Spacer()
                }
                .padding()
            }
            .padding()
        }
    }
}
#endif
