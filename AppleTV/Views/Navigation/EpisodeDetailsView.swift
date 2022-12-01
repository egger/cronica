//
//  EpisodeDetailsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let id: Int
    let season: Int
    @State private var isWatched = false
    @Binding var inWatchlist: Bool
    var body: some View {
        ZStack {
            WebImage(url: episode.itemImageOriginal)
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
                        .fill(.ultraThinMaterial)
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
                HStack(alignment: .bottom) {
                    VStack {
                        Text(episode.itemTitle)
                            .lineLimit(1)
                            .font(.title3)
                        GlanceInfo(info: episode.itemInfo)
                            .padding([.bottom, .top], 6)
                        ItemContentOverview(overview: episode.itemOverview)
                    }
                    .frame(maxWidth: 900)
                    Spacer()
                    VStack {
                        HStack {
                            WatchEpisodeButton(episode: episode,
                                                   season: season,
                                                   show: id,
                                                   isWatched: $isWatched,
                                                   inWatchlist: $inWatchlist)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .task {
            isWatched = PersistenceController.shared.isEpisodeSaved(show: id, season: season, episode: episode.id)
        }
    }
}
