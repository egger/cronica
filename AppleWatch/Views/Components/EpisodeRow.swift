//
//  EpisodeView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EpisodeRow: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @State private var isWatched: Bool = false
    var body: some View {
        HStack {
            WebImage(url: episode.itemImageMedium)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "tv")
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(
                    RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                     style: .continuous)
                )
                .overlay {
                    if isWatched {
                        ZStack {
                            Color.black.opacity(0.6)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                             style: .continuous)
                        )
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                    }
                }
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(episode.itemTitle)
                    .lineLimit(DrawingConstants.lineLimit)
                    .font(.callout)
                Text("E\(episode.itemEpisodeNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .task {
            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
        }
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 45
    static let lineLimit: Int = 1
}
