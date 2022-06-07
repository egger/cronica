//
//  EpisodeView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI

struct EpisodeView: View {
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
            NavigationView {
                ScrollView {
                    VStack {
                        HeroImage(url: episode.itemImageMedium, title: episode.itemTitle)
                            .frame(width: isPad ? DrawingConstants.padCoverImageWidth : DrawingConstants.heroImageWidth,
                                   height: isPad ? DrawingConstants.padCoverImageHeight : DrawingConstants.heroImageHeight)
                            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                        style: .continuous))
                            .shadow(radius: DrawingConstants.coverImageShadow)
                        OverviewBoxView(overview: episode.overview,
                                        title: episode.itemTitle,
                                        type: .tvShow)
                        .padding()
                    }
                }
                .navigationTitle(episode.itemTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button("Done") {
                            showDetails.toggle()
                        }
                    })
                }
            }
        })
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
    static let heroImageWidth: CGFloat = 360
    static let heroImageHeight: CGFloat = 210
    static let padCoverImageWidth: CGFloat = 500
    static let padCoverImageHeight: CGFloat = 300
    static let coverImageShadow: CGFloat = 6
}
