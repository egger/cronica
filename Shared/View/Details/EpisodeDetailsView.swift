//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @Binding var isWatched: Bool
    @Binding var isInWatchlist: Bool
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .accessibilityHidden(true)
#if os(iOS)
                    .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.imageWidth : 360,
                           height: (horizontalSizeClass == .regular) ? DrawingConstants.imageHeight : 210)
#else
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
#endif
                
                if let info = episode.itemInfo {
                    CenterHorizontalView {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding([.top, .horizontal])
                }
                
                WatchEpisodeButton(episode: episode,
                                       season: season,
                                       show: show,
                                       isWatched: $isWatched,
                                       inWatchlist: $isInWatchlist)
                .tint(isWatched ? .red : .blue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding([.top, .horizontal])
                .keyboardShortcut("e", modifiers: [.control])
#if os(iOS)
                .buttonBorderShape(.capsule)
#endif
                
                OverviewBoxView(overview: episode.itemOverview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
                
                CastListView(credits: episode.itemCast)
                
                AttributionView()
            }
            .task {
                load()
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.id,
                                       title: item.itemTitle,
                                       type: item.itemContentMedia,
                                       handleToolbarOnPopup: true)
#else
                ItemContentDetails(title: item.itemTitle,
                                id: item.id,
                                type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: [Person].self) { item in
                DetailedPeopleList(items: item)
            }
#if os(iOS)
            .navigationTitle(episode.itemTitle)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .background {
            TranslucentBackground(image: episode.itemImageLarge)
        }
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
    }
}

private struct DrawingConstants {
    static let titleLineLimit: Int = 1
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 500
    static let imageHeight: CGFloat = 300
#if os(iOS)
    static let imageRadius: CGFloat = 8
#else
    static let imageRadius: CGFloat = 12
#endif
}
