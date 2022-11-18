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
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
#if os(macOS)
#else
    @State private var isPad: Bool = UIDevice.isIPad
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    var body: some View {
        VStack {
            ScrollView {
#if os(macOS)
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: DrawingConstants.padImageWidth,
                           height: DrawingConstants.padImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
#else
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                           height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
#endif
                
                if let info = episode.itemInfo {
                    CenterHorizontalView {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding([.top, .horizontal])
                }
                
                WatchEpisodeButtonView(episode: episode,
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
                
                OverviewBoxView(overview: episode.overview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
                
                CastListView(credits: episode.itemCast)
                
                AttributionView()
            }
            .navigationTitle(episode.itemTitle)
            .task {
                load()
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
#else
                ItemContentView(title: item.itemTitle,
                                id: item.id,
                                type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .background {
            if newBackgroundStyle {
                ZStack {
                    WebImage(url: episode.itemImageLarge)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .padding(.zero)
                    Rectangle()
                        .fill(.regularMaterial)
                        .ignoresSafeArea()
                        .padding(.zero)
                }
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
