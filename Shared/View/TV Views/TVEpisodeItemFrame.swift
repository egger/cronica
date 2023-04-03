//
//  EpisodeItemFrame.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TVEpisodeItemFrame: View {
    let episode: Episode
    let show: Int
    @State private var isWatched = false
    private let persistence = PersistenceController.shared
    var body: some View {
        WebImage(url: episode.itemImageLarge)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    VStack {
                        Text(episode.itemTitle)
                            .font(.callout)
                            .lineLimit(1)
                            .padding()
                        Image(systemName: "tv")
                            .font(.title3)
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(
                    RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                     style: .continuous)
                )
            }
            .overlay {
                if isWatched {
                    ZStack {
                        Color.black.opacity(0.4)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(
                RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                 style: .continuous)
            )
            .task {
                withAnimation {
                    guard let season = episode.seasonNumber else { return }
                    isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
                }
            }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 200
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
 
