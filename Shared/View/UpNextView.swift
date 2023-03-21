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
        predicate: NSPredicate(format: "displayOnUpNext == %d", true)
    ) var items: FetchedResults<WatchlistItem>
    @State private var isLoaded = false
    @State private var episodes = [Episode]()
    @State private var selectedEpisode: Episode?
    @State private var isWatched = false
    @State private var isInWatchlist = true
    @State private var episodeShowID = [String:Int]()
    @State private var selectedEpisodeShowID: Int?
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                TitleView(title: "upNext")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(episodes) { episode in
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
                        }
                    }
                }.redacted(reason: isLoaded ? [] : .placeholder)
            }
            .task { await load() }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    if let show = selectedEpisodeShowID {
                        EpisodeDetailsView(episode: item, season: item.itemSeasonNumber, show: show, isWatched: $isWatched, isInWatchlist: $isInWatchlist)
                            .toolbar {
                                Button("Done") { selectedEpisode = nil }
                            }
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
#endif
                    } else {
                        ProgressView()
                    }
                }
                .presentationDetents([.medium, .large])
                .appTheme()
                .appTint()
                .task {
                    let showId = self.episodeShowID["\(item.id)"]
                    selectedEpisodeShowID = showId
                }
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
                    if result.isItemReleased {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                episodes.append(result)
                                episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
                            }
                        }
                    }
                } catch {
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
                    return nextEpisode
                }
                return nil
            }
            else {
                let nextEpisode = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                return nextEpisode[0]
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "fetchNextEpisode")
            return nil
        }
    }
}


struct UpNextView_Previews: PreviewProvider {
    static var previews: some View {
        UpNextView()
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
                .frame(width: 280, height: 160)
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
        .frame(width: 280, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 2.5)
    }
}
