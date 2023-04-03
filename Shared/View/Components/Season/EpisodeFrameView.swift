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
            image
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
                    if SettingsStore.shared.markEpisodeWatchedOnTap {
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
            HStack {
                Text("Episode \(episode.episodeNumber ?? 0)")
                    .textCase(.uppercase)
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
        .sheet(isPresented: $showDetails) {
            NavigationStack {
                EpisodeDetailsView(episode: episode, season: season, show: show, isWatched: $isWatched, isInWatchlist: $isInWatchlist)
                    .environmentObject(viewModel)
                    .toolbar {
                        ToolbarItem {
                            Button("Done") { showDetails = false }
                        }
                    }
            }
            .appTheme()
            .presentationDetents([.large])
#if os(macOS)
            .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
        }
    }
    
    private var image: some View {
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
                        Color.black.opacity(0.3)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .opacity(0.6)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .accessibilityHidden(true)
                }
            }
            .onTapGesture {
                if SettingsStore.shared.markEpisodeWatchedOnTap {
                    markAsWatched()
                    return
                }
                showDetails.toggle()
            }
            .applyHoverEffect()
    }
    
    private func markAsWatched() {
        Task {
            if !viewModel.isItemInWatchlist {
                await addToWatchlist()
            }
            let nextEpisodeNumber = episode.itemEpisodeNumber + 1
            guard let episodes = viewModel.season?.episodes else  {
                save()
                return
            }
            print("Episodes count: \(episodes.count)")
            print("Next episode: \(nextEpisodeNumber)")
            print("Next episode content: \(episodes[nextEpisodeNumber])")
            if episode.itemEpisodeNumber <= episodes.count {
                var nextEpisode: Episode?
                // An array always start at 0, so the episode number value will always represent the next item in the array
                nextEpisode = episodes[episode.itemEpisodeNumber]
                save(nextEpisode)
            } else {
                let nextSeason = try await NetworkService.shared.fetchSeason(id: show, season: season + 1)
                guard let nextEpisode = nextSeason.episodes?.first else {
                    save()
                    return
                }
                save(nextEpisode)
            }
        }
    }
    
    private func save(_ nextEpisode: Episode? = nil) {
        PersistenceController.shared.updateEpisodeList(show: show,
                                                       season: season,
                                                       episode: episode.id,
                                                       nextEpisode: nextEpisode)
        withAnimation { isWatched.toggle() }
    }
    
    private func addToWatchlist() async {
        do {
            let item = try await NetworkService.shared.fetchItem(id: show, type: .tvShow)
            PersistenceController.shared.save(item)
            DispatchQueue.main.async {
                withAnimation {
                    viewModel.isItemInWatchlist.toggle()
                }
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "EpisodeFrameView.addToWatchlist")
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
