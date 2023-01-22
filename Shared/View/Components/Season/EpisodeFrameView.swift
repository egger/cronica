//
//  EpisodeFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI
import SDWebImageSwiftUI

/// A view that displays a frame with an image, episode number, title, and two line overview,
/// on tap it display a sheet view with more information.
struct EpisodeFrameView: View {
    let episode: Episode
    let season: Int
    let show: Int
    var itemLink: URL
    private let persistence = PersistenceController.shared
    @AppStorage("markEpisodeWatchedTap") private var episodeTap = false
    @State private var isWatched = false
    @State private var showDetails = false
    @Binding var isInWatchlist: Bool
    @EnvironmentObject var viewModel: SeasonViewModel
    init(episode: Episode, season: Int, show: Int, isInWatchlist: Binding<Bool>) {
        self.episode = episode
        self.season = season
        self.show = show
        self._isInWatchlist = isInWatchlist
        itemLink = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.episodeNumber ?? 1)")!
    }
    var body: some View {
        VStack {
            WebImage(url: episode.itemImageMedium)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        VStack {
                            Text(episode.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.bottom)
                            Image(systemName: "tv")
                                .font(.title)
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .accessibilityHidden(true)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(
                    RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                     style: .continuous)
                )
                .overlay {
                    if isWatched {
                        ZStack {
                            Color.black.opacity(0.4)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                    }
                }
                .contextMenu {
                    WatchEpisodeButton(episode: episode,
                                       season: season,
                                       show: show,
                                       isWatched: $isWatched,
                                       inWatchlist: $isInWatchlist)
                    if let number = episode.episodeNumber {
                        if number != 1 && !isWatched {
                            Button("Mark this and previous episodes as watched") {
                                Task {
                                    await viewModel.markThisAndPrevious(until: episode.id, show: show)
                                }
                            }
                        }
                    }
                    if episodeTap {
                        Button("Show Details") {
                            showDetails.toggle()
                        }
                    }
#if os(tvOS)
                    Button("Cancel") { }
#else
                    ShareLink(item: itemLink)
#endif
                }
                .applyHoverEffect()
            HStack {
                Text("Episode \(episode.episodeNumber ?? 0)")
                    .textCase(.uppercase)
                    .fontDesign(.rounded)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 1)
            HStack {
                Text(episode.itemTitle)
                    .font(.callout)
                    .lineLimit(1)
                Spacer()
            }
            HStack {
                Text(episode.itemOverview)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                Spacer()
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .task {
            withAnimation {
                isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
            }
        }
        .onTapGesture {
#if os(macOS)
            markAsWatched()
#else
            if episodeTap {
                markAsWatched()
                return
            }
            showDetails.toggle()
#endif
        }
        .sheet(isPresented: $showDetails) {
#if os(tvOS)
            EmptyView()
#else
            NavigationStack {
                EpisodeDetailsView(episode: episode, season: season, show: show, isWatched: $isWatched, isInWatchlist: $isInWatchlist)
                    .environmentObject(viewModel)
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                showDetails = false
                            }
                        }
                    }
#if os(macOS)
                    .frame(width: 900, height: 500)
#endif
            }
            .appTheme()
#endif
        }
    }
    
    private func markAsWatched() {
        PersistenceController.shared.updateEpisodeList(show: show,
                                                       season: season,
                                                       episode: episode.id)
        withAnimation {
            isWatched.toggle()
        }
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 200
    static let imageRadius: CGFloat = 12
#else
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
#endif
    static let titleLineLimit: Int = 1
}
