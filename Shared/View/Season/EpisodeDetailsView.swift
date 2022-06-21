//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    var episode: Episode
    @Binding var showDetails: Bool
    @State private var isPad: Bool = UIDevice.isIPad
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
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
                .navigationTitle(episode.itemTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("Done") {
                            showDetails.toggle()
                        }
                    }
                }
            }
        }
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
