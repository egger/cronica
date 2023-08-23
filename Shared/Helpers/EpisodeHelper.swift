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
			guard let seasonNumber = episode.seasonNumber else { return nil }
            let season = try await network.fetchSeason(id: show, season: seasonNumber)
            guard let episodes = season.episodes else { return nil }
            if episodes.isEmpty { return nil }
			guard let actualEpisodeNumber = episode.episodeNumber, let actualSeasonNumber = episode.seasonNumber
			else { return nil }
            let nextEpisodeCount = actualEpisodeNumber+1
            if episodes.contains(where: { $0.episodeNumber == nextEpisodeCount}) {
                let nextEpisode = episodes.filter { $0.episodeNumber == nextEpisodeCount }
                guard let episode = nextEpisode.first else { return nil }
                return episode
            } else {
                let nextSeasonNumber = actualSeasonNumber + 1
                let nextSeason = try await network.fetchSeason(id: show, season: nextSeasonNumber)
                guard let episodes = nextSeason.episodes else { return nil }
                if episodes.isEmpty { return nil }
                guard let nextEpisode = episodes.first else { return nil }
				let showContent = try? await network.fetchItem(id: show, type: .tvShow)
				let isReleased = showContent?.itemStatus == .ended ? true : nextEpisode.isItemReleased
                if isReleased {
                    return nextEpisode
                }
                return nil
            }
        } catch {
            if Task.isCancelled { return nil }
            let message = "Episode:\(episode.seasonNumber as Any)\nSeason:\(episode.seasonNumber as Any)\nShow: \(show).\nError: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "EpisodeHelper.fetchNextEpisode")
            return nil
        }
    }
}
