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
    private let persistence = PersistenceController.shared
    @State private var isItemSaved = false
    var body: some View {
        Button(action: update) {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "rectangle.fill.badge.minus" : "rectangle.fill.badge.checkmark")
#if os(tvOS)
            .padding()
#endif
        }
    }
    
    private func update() {
        checkIfItemIsSaved()
        if !isItemSaved {
            Task {
                await fetch()
                handleList()
            }
        } else {
            handleList()
        }
    }
    
    private func checkIfItemIsSaved() {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        let isShowSaved = persistence.isItemSaved(id: contentId)
        isItemSaved = isShowSaved
    }
    
    private func handleList() {
        do {
            let contentId = "\(show)@\(MediaType.tvShow.toInt)"
            let item = try persistence.fetch(for: contentId)
            guard let item else { return }
            persistence.updateWatchedEpisodes(for: item, with: episode)
            DispatchQueue.main.async {
                withAnimation { isWatched.toggle() }
            }
            HapticManager.shared.successHaptic()
            Task {
                let nextEpisode = await fetchNextEpisode()
                guard let nextEpisode else { return }
                persistence.updateUpNext(item, episode: nextEpisode)
            }
        } catch {
            CronicaTelemetry.shared.handleMessage("", for: "")
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
                    isItemSaved = true
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
            if Task.isCancelled { return nil }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "fetchNextEpisode")
            return nil
        }
    }
}
