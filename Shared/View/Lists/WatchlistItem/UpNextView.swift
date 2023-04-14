//
//  UpNextView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct UpNextView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "displayOnUpNext == %d", true),
            NSPredicate(format: "isArchive == %d", false)
        ])
    ) var items: FetchedResults<WatchlistItem>
    @State private var isLoaded = false
    @State private var episodes = [Episode]()
    @State private var selectedEpisode: Episode?
    @State private var isWatched = false
    @State private var isInWatchlist = true
    @State private var episodeShowID = [String:Int]()
    @State private var selectedEpisodeShowID: Int?
    @Binding var shouldReload: Bool
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !episodes.isEmpty {
                    TitleView(title: "upNext")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(episodes) { episode in
#if os(tvOS)
                                Button {
                                    selectedEpisode = episode
                                } label: {
                                    UpNextEpisodeCard(episode: episode)
                                }
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, episode.id == self.episodes.first!.id ? 16 : 0)
                                .padding(.trailing, episode.id == self.episodes.last!.id ? 16 : 0)
                                .padding(.bottom)
                                .padding(.top, 8)
                                .buttonStyle(.card)
#else
                                UpNextEpisodeCard(episode: episode)
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, episode.id == self.episodes.first!.id ? 16 : 0)
                                    .padding(.trailing, episode.id == self.episodes.last!.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
                                    .onTapGesture {
                                        if SettingsStore.shared.markEpisodeWatchedOnTap {
                                            Task { await markAsWatched(episode) }
                                        } else {
                                            selectedEpisode = episode
                                        }
                                    }
#endif
                            }
                        }
                    }
                    .redacted(reason: isLoaded ? [] : .placeholder)
                }
            }
            .task { await load() }
            .onChange(of: shouldReload) { reload in
                if reload {
                    isLoaded = false
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            episodes.removeAll()
                        }
                    }
                    Task {
                        await load()
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                shouldReload = false
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    if let show = selectedEpisodeShowID {
#if os(tvOS)
                        TVEpisodeDetailsView(episode: item, id: show, season: item.itemSeasonNumber, inWatchlist: $isInWatchlist)
#else
                        EpisodeDetailsView(episode: item, season: item.itemSeasonNumber, show: show, isWatched: $isWatched, isInWatchlist: $isInWatchlist)
                            .toolbar {
                                Button("Done") { selectedEpisode = nil }
                            }
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
#endif
#endif
                    } else {
                        ProgressView()
                    }
                }
                .presentationDetents([.medium, .large])
#if os(iOS)
                .appTheme()
                .appTint()
#endif
                .task {
                    let showId = self.episodeShowID["\(item.id)"]
                    selectedEpisodeShowID = showId
                }
#if os(macOS)
                .frame(width: 800, height: 500)
#endif
            }
            .task(id: isWatched) {
                if isWatched {
                    guard let selectedEpisode else { return }
                    await handleWatched(selectedEpisode)
                    self.selectedEpisode = nil
                }
            }
        }
    }
    
    private func load() async {
        if !isLoaded {
            for item in items {
                do {
                    let result = try await NetworkService.shared.fetchEpisode(tvID: item.id,
                                                                              season: item.seasonNumberUpNext,
                                                                              episodeNumber: item.nextEpisodeNumberUpNext)
                    let isWatched = PersistenceController.shared.isEpisodeSaved(show: item.itemId,
                                                                                    season: result.itemSeasonNumber,
                                                                                    episode: result.id)
                    if result.isItemReleased && !isWatched {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                episodes.append(result)
                                episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
                            }
                        }
                    }
                } catch {
                    if Task.isCancelled { return }
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "UpNextView.load")
                }
            }
            DispatchQueue.main.async {
                withAnimation { self.isLoaded = true }
            }
        }
    }
    
    private func markAsWatched(_ episode: Episode) async {
        let showId = self.episodeShowID["\(episode.id)"]
        guard let showId else { return }
        let persistence = PersistenceController.shared
        let nextEpisode = await fetchNextEpisode(for: episode)
        persistence.updateEpisodeList(show: showId,
                                      season: episode.itemSeasonNumber,
                                      episode: episode.id,
                                      nextEpisode: nextEpisode)
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.episodes.insert(nextEpisode, at: 0)
                        self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.id == episode.id })
            }
        }
        HapticManager.shared.successHaptic()
    }
    
    private func handleWatched(_ episode: Episode) async {
        let showId = self.episodeShowID["\(episode.id)"]
        guard let showId else { return }
        let nextEpisode = await fetchNextEpisode(for: episode)
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.episodes.insert(nextEpisode, at: 0)
                        self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.id == episode.id })
            }
        }
    }
    
    private func fetchNextEpisode(for actual: Episode) async -> Episode? {
        do {
            let showId = self.episodeShowID["\(actual.id)"]
            guard let showId else { return nil }
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: showId, season: actual.itemSeasonNumber)
            guard let episodes = season.episodes else { return nil }
            let nextEpisodeCount = actual.itemEpisodeNumber+1
            if episodes.count < nextEpisodeCount {
                let nextSeasonNumber = actual.itemSeasonNumber + 1
                let nextSeason = try await network.fetchSeason(id: showId, season: nextSeasonNumber)
                guard let episodes = nextSeason.episodes else { return nil }
                let nextEpisode = episodes[0]
                if nextEpisode.isItemReleased {
                    if PersistenceController.shared.isEpisodeSaved(show: showId,
                                                                   season: nextEpisode.itemSeasonNumber,
                                                                   episode: nextEpisode.id) { return nil }
                    return nextEpisode
                }
                return nil
            }
            else {
                let nextEpisodeArray = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                let nextEpisode = nextEpisodeArray[0]
                if PersistenceController.shared.isEpisodeSaved(show: showId,
                                                               season: nextEpisode.itemSeasonNumber,
                                                               episode: nextEpisode.id) { return nil }
                return nextEpisode
            }
        } catch {
            if Task.isCancelled { return nil }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "UpNextView.fetchNextEpisode.failed")
            return nil
        }
    }
    
}

private struct UpNextEpisodeCard: View {
    let episode: Episode
    var body: some View {
        ZStack {
            WebImage(url: episode.itemImageLarge)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
                .transition(.opacity)
            
            VStack(alignment: .leading) {
                Spacer()
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.4)
                        .frame(height: 50)
                        .mask {
                            LinearGradient(colors: [Color.black,
                                                    Color.black.opacity(0.924),
                                                    Color.black.opacity(0.707),
                                                    Color.black.opacity(0.383),
                                                    Color.black.opacity(0)],
                                           startPoint: .bottom,
                                           endPoint: .top)
                        }
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 70)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 50)
                                Rectangle()
                            }
                        }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(episode.itemTitle)
                                .font(.callout)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text("E\(episode.itemEpisodeNumber), S\(episode.itemSeasonNumber)")
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.leading)
                }
            }
        }
        .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 2.5)
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let imageWidth: CGFloat = 660
    static let imageHeight: CGFloat = 360
#else
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#endif
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
