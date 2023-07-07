//
//  EpisodeHelper.swift
//  Story
//
//  Created by Alexandre Madeira on 08/05/23.
//

import Foundation

class EpisodeHelper {
    private let network = NetworkService.shared
    
    func fetchNextEpisode(for episode: Episode, show: Int) async -> Episode? {
        do {
            let season = try await network.fetchSeason(id: show, season: episode.itemSeasonNumber)
            guard let episodes = season.episodes else { return nil }
            if episodes.isEmpty { return nil }
            let nextEpisodeCount = episode.itemEpisodeNumber+1
            if episodes.contains(where: { $0.itemEpisodeNumber == nextEpisodeCount}) {
                let nextEpisode = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                guard let episode = nextEpisode.first else { return nil }
                return episode
            } else {
                let nextSeasonNumber = episode.itemSeasonNumber + 1
                let nextSeason = try await network.fetchSeason(id: show, season: nextSeasonNumber)
                guard let episodes = nextSeason.episodes else { return nil }
                if episodes.isEmpty { return nil }
                guard let nextEpisode = episodes.first else { return nil }
                if nextEpisode.isItemReleased {
                    return nextEpisode
                }
                return nil
            }
        } catch {
            if Task.isCancelled { return nil }
            let message = "Episode:\(episode.itemEpisodeNumber)\nSeason:\(episode.itemSeasonNumber)\nShow: \(show).\nError: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "EpisodeHelper.fetchNextEpisode")
            return nil
        }
    }
}
