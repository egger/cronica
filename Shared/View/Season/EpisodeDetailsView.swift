//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//
import SwiftUI
import SDWebImageSwiftUI
#if os(iOS) || os(macOS)
struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @Binding var isWatched: Bool
    @State private var isInWatchlist = false
    var isUpNext = false
    @State private var showItem: ItemContent?
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
                    .padding(.top)
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
                                   isWatched: $isWatched)
                .tint(isWatched ? .red : .blue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .keyboardShortcut("e", modifiers: [.control])
#if os(iOS)
                .buttonBorderShape(.capsule)
#endif
                
#if os(iOS)
                if let showItem {
                    NavigationLink(value: showItem) {
                        Label("tvShowDetails", systemImage: "chevron.forward")
                            .foregroundColor(.white)
                            .frame(minWidth: 100)
                    }
                    .tint(.black)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding([.horizontal, .top])
                    .buttonBorderShape(.capsule)
                }
#endif
                
                OverviewBoxView(overview: episode.itemOverview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
                
                CastListView(credits: episode.itemCast)
                
                AttributionView()
            }
            .navigationTitle(episode.itemTitle)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .task { load() }
            .onAppear {
                if isUpNext {
                    Task {
                        showItem = try? await NetworkService.shared.fetchItem(id: show, type: .tvShow)
                    }
                }
            }
        }
        .background {
            TranslucentBackground(image: episode.itemImageLarge)
        }
    }
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
    }
    
    private func checkIfItemIsSaved() {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        let isShowSaved = persistence.isItemSaved(id: contentId)
        isInWatchlist = isShowSaved
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
#endif
