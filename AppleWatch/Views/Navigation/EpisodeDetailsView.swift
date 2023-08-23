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
    var showTitle = String()
    @Binding var isWatched: Bool
    private let persistence = PersistenceController.shared
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
                
                Text(showTitle)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
					.padding(.horizontal)
                Text(episode.itemTitle)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Text("S\(season), E\(episode.itemEpisodeNumberDisplay)")
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .bottom])
                
                WatchEpisodeButton(episode: episode, season: season, show: show, isWatched: $isWatched)
                    .buttonStyle(.borderedProminent)
                    .tint(isWatched ? .orange : .green)
                    .padding([.bottom, .horizontal])
                    .onAppear(perform: load)
                
                if let url = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.itemEpisodeNumberDisplay)") {
                    ShareLink(item: url)
						.padding(.horizontal)
                        .padding([.bottom, .horizontal])
                }
                
                AboutSectionView(about: episode.itemOverview)
					.padding([.horizontal, .bottom])
                
            }
        }
//        .background {
//            if #available(watchOS 10, *) {
//                TranslucentBackground(image: episode.itemImageMedium)
//            }
//        }
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show,
                                                 season: season,
                                                 episode: episode.id)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 324
    static let imageHeight: CGFloat = 163
    static let lineLimit: Int = 1
}
