//
//  EpisodeDetailsView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    var itemLink: URL
    private let persistence = PersistenceController.shared
    @State var isWatched = false
    init(episode: Episode, season: Int, show: Int) {
        self.episode = episode
        self.season = season
        self.show = show
        itemLink = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.episodeNumber ?? 1)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageMedium,
                          title: episode.itemTitle)
                .clipShape(
                    RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                     style: .continuous)
                )
                .padding()
                
                WatchEpisodeButton(episode: episode, season: season, show: show, isWatched: $isWatched)
                    .buttonStyle(.borderedProminent)
                    .tint(isWatched ? .orange : .green)
                    .padding([.bottom, .horizontal])
                
                ShareLink(item: itemLink)
                    .padding([.bottom, .horizontal])
                
                AboutSectionView(about: episode.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
            }
        }
        .navigationTitle(episode.itemTitle)
        .task {
            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
        }
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 324
    static let imageHeight: CGFloat = 163
    static let lineLimit: Int = 1
}
