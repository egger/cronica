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
    @Binding private var isInWatchlist: Bool
    init(episode: Episode, season: Int, show: Int, inWatchlist: Binding<Bool>) {
        self.episode = episode
        self.season = season
        self.show = show
        self._isInWatchlist = inWatchlist
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: isPad ? DrawingConstants.padCoverImageWidth : DrawingConstants.heroImageWidth,
                           height: isPad ? DrawingConstants.padCoverImageHeight : DrawingConstants.heroImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.coverImageShadow)

                if let info = episode.itemInfo {
                    HStack {
                        Spacer()
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding([.top, .horizontal])
                }
                
                WatchEpisodeButtonView(episode: episode,
                                       season: season,
                                       show: show,
                                       isWatched: $isWatched,
                                       inWatchlist: $isInWatchlist)
                    .tint(isWatched ? .red : .blue)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding([.top, .horizontal])
                    .keyboardShortcut("e", modifiers: [.control])
                
                OverviewBoxView(overview: episode.overview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
                
                CastListView(credits: episode.itemCast)
                
                AttributionView()
            }
            .navigationTitle(episode.itemTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                load()
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
        }
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
