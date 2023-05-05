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
                        if let seasons = viewModel.content?.itemSeasons {
                            SeasonList(showID: id, numberOfSeasons: seasons)
                        }
                        TVItemContentList(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "")
                        TVCastListView(credits: viewModel.credits)
                            .padding(.bottom)
                        AttributionView()
                    }
                }
                .task { await viewModel.load() }
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
            }
            .ignoresSafeArea()
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
                HStack {
                    Text(title)
                        .font(.title3)
                        .lineLimit(1)
                        .fontWeight(.semibold)
                        .padding()
                    Spacer()
                }
                .padding(.leading)
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
                                .frame(minWidth: 480)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(width: 480)
                            Button {
                                viewModel.update(.watched)
                            } label: {
                                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
                                    .padding([.top, .bottom])
                                    .frame(minWidth: 480)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(width: 480)
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
                                .frame(maxWidth: 800)
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
                    Spacer()
                    Button {
                        
                    } label: {
                        VStack(alignment: .leading) {
                            if let item = viewModel.content {
                                InfoSegmentView(title: "Release Date", info: item.itemTheatricalString)
                                InfoSegmentView(title: "Genre", info: item.itemGenre)
                                if type == .tvShow {
                                    InfoSegmentView(title: "Production Company", info: item.itemCompany)
                                } else {
                                    InfoSegmentView(title: "Run Time", info: item.itemRuntime)
                                }
                            }
                            
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding()
            }
            .padding()
        }
    }
}

struct InfoSegmentView: View {
    let title: String
    let info: String?
    var body: some View {
        if let info {
            VStack(alignment: .leading) {
                Text(NSLocalizedString(title, comment: ""))
                    .lineLimit(1)
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(info)
                    .lineLimit(1)
                    .font(.body)
            }
        }
    }
}
#endif
