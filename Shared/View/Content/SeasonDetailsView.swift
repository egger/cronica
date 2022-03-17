//
//  SeasonDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import SwiftUI

struct SeasonDetailsView: View {
    var id: Int
    var seasonNumber: Int
    var title: String
    @StateObject private var viewModel: SeasonViewModel
    init(id: Int, seasonNumber: Int, title: String) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.id = id
        self.seasonNumber = seasonNumber
        self.title = title
    }
    var body: some View {
        ScrollView {
            if let season = viewModel.season {
                VStack {
                    if season.episodes != nil  && !season.episodes!.isEmpty {
                        Section {
                            ForEach(season.episodes!) { item in
                                EpisodeCardView(episode: item)
                                    .padding(4)
                            }
                        }
                    }
                }
                .navigationTitle(title)
            }
        }
        .task {
            load()
        }
    }
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: id, seasonNumber: seasonNumber)
        }
    }
}

private struct EpisodeCardView: View {
    let episode: Episode
    var body: some View {
        HStack {
            AsyncImage(url: episode.itemImageMedium) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.secondary
                    ProgressView()
                }
            }
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                Text(episode.itemTitle)
                    .lineLimit(1)
                    .font(.callout)
                    .padding([.top, .bottom], 2)
                Text(episode.itemAbout)
                    .lineLimit(2)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer()
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 80
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
