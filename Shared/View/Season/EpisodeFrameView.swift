//
//  EpisodeFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI

/// A view that displays a frame with an image, episode number, title, and two line overview,
/// on tap it display a sheet view with more information.
struct EpisodeFrameView: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @State private var isWatched: Bool = false
    @State private var isPad: Bool = UIDevice.isIPad
    init(episode: Episode, season: Int, show: Int) {
        self.episode = episode
        self.season = season
        self.show = show
    }
    var body: some View {
        VStack {
            AsyncImage(url: episode.itemImageMedium,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                } else {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            Text(episode.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.bottom)
                            Image(systemName: "tv")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                        style: .continuous))
            .contextMenu {
                Button(action: {
                    withAnimation {
                        isWatched.toggle()
                    }
                    persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
                }, label: {
                    Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                          systemImage: isWatched ? "minus.circle" : "checkmark.circle")
                })
            }
            HStack {
                Text("Episode \(episode.episodeNumber ?? 0)")
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 1)
            HStack {
                Text(episode.itemTitle)
                    .font(.callout)
                    .lineLimit(1)
                Spacer()
            }
            HStack {
                Text(episode.itemOverview)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .task {
            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
}
