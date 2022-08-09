//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @State private var isPad: Bool = UIDevice.isIPad
    @State private var isWatched: Bool = false
    init(episode: Episode, season: Int, show: Int) {
        self.episode = episode
        self.season = season
        self.show = show
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageMedium, title: episode.itemTitle)
                    .frame(width: isPad ? DrawingConstants.padCoverImageWidth : DrawingConstants.heroImageWidth,
                           height: isPad ? DrawingConstants.padCoverImageHeight : DrawingConstants.heroImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.coverImageShadow)
                
                Button(action: {
                    updateWatched()
                }, label: {
                    Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                          systemImage: isWatched ? "minus.circle" : "checkmark.circle")
                })
                .tint(isWatched ? .red : .blue)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding([.top, .horizontal])
                
                OverviewBoxView(overview: episode.overview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
            }
            .navigationTitle(episode.itemTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                load()
            }
        }
    }
    
    private func updateWatched() {
        withAnimation {
            isWatched.toggle()
        }
        persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
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
