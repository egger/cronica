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
                
                WatchEpisodeButton(episode: episode,
                                   season: season,
                                   show: show,
                                   isWatched: $isWatched,
                                   inWatchlist: $isInWatchlist)
                .tint(isWatched ? .red : .blue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
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
            .navigationTitle(episode.itemTitle)
            .task {
                load()
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
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
            .navigationDestination(for: ProductionCompany.self) { item in
                CompanyDetails(company: item)
            }
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
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
