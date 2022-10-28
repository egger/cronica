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
    @Binding var isWatched: Bool
    @Binding var isInWatchlist: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                           height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                
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
#if os(tvOS)
#else
                ItemContentView(title: item.itemTitle,
                                id: item.id,
                                type: item.itemContentMedia,
                                image: item.cardImageMedium)
#endif
            }
            .navigationDestination(for: Person.self) { person in
#if os(tvOS)
#else
                PersonDetailsView(title: person.name, id: person.id)
#endif
            }
        }
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
    }
}

private struct DrawingConstants {
    static let titleLineLimit: Int = 1
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
