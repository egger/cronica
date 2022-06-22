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
    @State private var showDetails: Bool = false
    @State private var isPad: Bool = UIDevice.isIPad
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
        .onTapGesture {
            showDetails.toggle()
        }
        .sheet(isPresented: $showDetails, content: {
            EpisodeDetailsView(episode: episode, showDetails: $showDetails)
        })
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
}
