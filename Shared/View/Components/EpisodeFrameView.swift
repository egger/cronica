//
//  EpisodeFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI

struct EpisodeFrameView: View {
    let episode: Episode
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
            .frame(width: 160, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8,
                                        style: .continuous))
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
                Text(episode.overview ?? "Not Available")
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
