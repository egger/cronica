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
    @EnvironmentObject var viewModel: SeasonViewModel
    @State private var isWatched = false
    @State private var showDetails = false
    init(episode: Episode, season: Int, show: Int) {
        self.episode = episode
        self.season = season
        self.show = show
        itemLink = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.itemEpisodeNumber)")!
    }
    var body: some View {
#if os(tvOS)
        VStack {
            Button {
                showDetails.toggle()
            } label: {
                image
                    .accessibilityElement(children: .combine)
                    .task {
                        withAnimation {
                            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
                        }
                    }
            }
            .buttonStyle(.card)
            information
        }
        .padding(.top)
#else
        VStack {
            image
                .contextMenu {
                    WatchEpisodeButton(episode: episode,
                                       season: season,
                                       show: show,
                                       isWatched: $isWatched)
#if os(iOS) || os(macOS)
                    ShareLink(item: itemLink)
#endif
                }
            information
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .task {
            withAnimation {
                isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
            }
        }
#endif
    }
    
    private var information: some View {
        VStack {
            HStack {
                Text("Episode \(episode.itemEpisodeNumber)")
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
            .applyHoverEffect()
            .onTapGesture {
                showDetails.toggle()
            }
            .sheet(isPresented: $showDetails) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    EpisodeDetailsView(episode: episode, season: season, show: show, isWatched: $isWatched)
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
#else
                TVEpisodeDetailsView(episode: episode, id: show, season: season)
#endif
            }
#if os(tvOS)
            .frame(maxWidth: 360)
#endif
    }
    
    private func markAsWatched() {
        Task {
            if !viewModel.isItemInWatchlist {
                await addToWatchlist()
            }
            guard let episodes = viewModel.season?.episodes else  {
                save()
                return
            }
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