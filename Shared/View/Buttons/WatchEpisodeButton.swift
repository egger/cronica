//
//  WatchEpisodeButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 15/08/22.
//

import SwiftUI

struct WatchEpisodeButton: View {
    let episode: Episode
    let season: Int
    let show: Int
    @Binding var isWatched: Bool
    @Binding var inWatchlist: Bool
    private let persistence = PersistenceController.shared
    @State private var errorMessage = false
    var body: some View {
        Button {
            update()
        } label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "rectangle.fill.badge.minus" : "rectangle.fill.badge.checkmark")
#if os(tvOS)
            .padding()
#endif
        }
    }
    
    private func update() {
        if !inWatchlist {
            Task {
                await fetch()
                await handleList()
            }
        } else {
            Task { await handleList() }
        }
        HapticManager.shared.successHaptic()
    }
    
    private func handleList() async {
        if SettingsStore.shared.markPreviouslyEpisodesAsWatched {
            Task {
                await persistence.updateEpisodeListUpTo(to: show, actualEpisode: episode)
            }
        } else {
            let nextEpisode = await fetchNextEpisode()
            persistence.updateEpisodeList(show: show, season: season, episode: episode.id, nextEpisode: nextEpisode)
        }
        
        DispatchQueue.main.async {
            withAnimation {
                isWatched.toggle()
            }
        }
    }
    
    private func fetch() async {
        let network = NetworkService.shared
        do {
            let content = try await network.fetchItem(id: show, type: .tvShow)
            persistence.save(content)
            if content.itemCanNotify && content.itemFallbackDate.isLessThanTwoMonthsAway() {
                NotificationManager.shared.schedule(content)
            }
            DispatchQueue.main.async {
                withAnimation {
                    inWatchlist = true
                }
            }
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "WatchEpisodeButton.fetch")
        }
    }
    
    private func fetchNextEpisode() async -> Episode? {
        do {
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: show, season: season)
            guard let episodes = season.episodes else { return nil }
            let nextEpisodeCount = episode.itemEpisodeNumber+1
            if episodes.count < nextEpisodeCount {
                let nextSeasonNumber = self.season + 1
                let nextSeason = try await network.fetchSeason(id: show, season: nextSeasonNumber)
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
