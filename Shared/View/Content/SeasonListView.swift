//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

struct SeasonListView: View {
    let title: String
    let id: Int
    let items: [Season]
    var body: some View {
        VStack {
            HStack {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.headline)
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        NavigationLink(destination: SeasonView(id: self.id,
                                                               season: item.seasonNumber,
                                                               title: item.itemTitle)) {
                            PosterView(title: item.itemTitle, url: item.posterImage)
                                .padding([.leading, .trailing], 4)
                        }
                                                               .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                                               .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                                               .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}

private struct SeasonView: View {
    var id: Int
    var season: Int
    var title: String
    @StateObject private var viewModel: SeasonViewModel
    @State private var showDetails: Bool = false
    init(id: Int, season: Int, title: String) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.id = id
        self.season = season
        self.title = title
    }
    var body: some View {
        ScrollView {
            if let season = viewModel.season {
                VStack {
                    if let items = season.episodes {
                        ForEach(items) { item in
                            NavigationLink(destination: EpisodeDetailsView(item: item)) {
                                EpisodeItemView(item: item)
                                    .padding(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .navigationTitle(title)
            }
        }
        .task { load() }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, season: self.season)
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 80
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}

private struct EpisodeDetailsView: View {
    let item: Episode
    var body: some View {
        ScrollView {
            VStack {
                HeroImage(url: item.itemImageLarge, title: item.itemTitle)
                GroupBox {
                    Text(item.itemAbout)
                        .padding([.top, .bottom], 4)
                } label: {
                    Label("About", systemImage: "tv")
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle(item.itemTitle)
        }
    }
}

private struct EpisodeItemView: View {
    let item: Episode
    var body: some View {
        HStack {
            AsyncImage(url: item.itemImageMedium) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                else if phase.error != nil {
                    ZStack {
                        Rectangle().fill(.secondary)
                        ProgressView()
                    }
                } else {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "tv")
                    }
                }
            }
            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .lineLimit(1)
                    .font(.callout)
                    .padding([.top, .bottom], 2)
                    .foregroundColor(.primary)
                Text(item.itemAbout)
                    .lineLimit(2)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer()
        }
    }
}
