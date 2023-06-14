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
    private let persistence = PersistenceController.shared
    @State private var isWatched = false
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
                
                Text("Episode \(episode.itemEpisodeNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                Text("Season \(episode.itemSeasonNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .bottom])
                
                WatchEpisodeButton(episode: episode, season: season, show: show, isWatched: $isWatched)
                    .padding([.bottom, .horizontal])
                    .onAppear(perform: load)
                
                if let url = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.itemEpisodeNumber)") {
                    ShareLink(item: url)
                        .padding([.bottom, .horizontal])
                }
                
                AboutSectionView(about: episode.itemOverview)
                
            }
        }
        .navigationTitle(episode.itemTitle)
        .background {
            if #available(watchOS 10, *) {
                TranslucentBackground(image: episode.itemImageMedium)
            }
        }
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show,
                                                 season: episode.itemSeasonNumber,
                                                 episode: episode.id)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 324
    static let imageHeight: CGFloat = 163
    static let lineLimit: Int = 1
}
