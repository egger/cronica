//
//  UpNextViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

@MainActor
class UpNextViewModel: ObservableObject {
    @Published private var episodeShowID = [String:Int]()
    @Published var isLoaded = false
    @Published var items = [UpNextEpisode]()
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    
    private func getNextEpisode(of actual: Episode) async -> Episode? {
        guard let showID = self.episodeShowID["\(actual.id)"] else { return nil }
        let season = try? await network.fetchSeason(id: showID, season: actual.itemSeasonNumber)
        guard let episodes = season?.episodes else { return nil }
        let episodeCount = actual.itemEpisodeNumber + 1
        if episodes.count < episodeCount {
            let nextSeasonNumber = actual.itemSeasonNumber + 1
            let nextSeason = try? await network.fetchSeason(id: showID, season: nextSeasonNumber)
            guard let nextSeasonEpisodes = nextSeason?.episodes else { return nil }
            let nextEpisode = nextSeasonEpisodes[0]
            if nextEpisode.isItemReleased {
                if persistence.isEpisodeSaved(show: showID, season: nextSeasonNumber, episode: nextEpisode.id) { return nil }
                return nextEpisode
            }
        } else {
            let nextEpisode = episodes.filter { $0.itemEpisodeNumber == episodeCount }
            if nextEpisode.isEmpty { return nil }
            let episode = nextEpisode[0]
            if persistence.isEpisodeSaved(show: showID, season: episode.itemSeasonNumber, episode: episode.id) { return nil }
            return episode
        }
        return nil
    }
    
    func load(_ items: FetchedResults<WatchlistItem>) async {
        if !isLoaded {
            for item in items {
                let result = try? await network.fetchEpisode(tvID: item.id,
                                                             season: item.seasonNumberUpNext,
                                                             episodeNumber: item.nextEpisodeNumberUpNext)
                if let result {
                    let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                               season: result.itemSeasonNumber,
                                                               episode: result.id)
                    
                    if result.isItemReleased && !isWatched {
                        let content = UpNextEpisode(id: result.id,
                                                    showTitle: item.itemTitle,
                                                    showID: item.itemId,
                                                    backupImage: item.image,
                                                    episode: result)
                        
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                self.items.append(content)
                                self.episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                withAnimation { self.isLoaded = true }
            }
        }
    }
    
    func reload(_ items: FetchedResults<WatchlistItem>) async {
        withAnimation { self.isLoaded = false }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.items.removeAll()
            }
        }
        Task { await load(items) }
    }
    
    func handleWatched(_ episode: Episode) async {
        let showId = self.episodeShowID["\(episode.id)"]
        guard let showId else { return }
        let nextEpisode = await getNextEpisode(of: episode)
        let item = try? await network.fetchItem(id: showId, type: .tvShow)
        guard let item else { return }
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: item.itemTitle,
                                            showID: showId,
                                            backupImage: item.cardImageLarge,
                                            episode: nextEpisode)
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.items.insert(content, at: 0)
                        self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.items.removeAll(where: { $0.episode.id == episode.id })
            }
        }
    }
}
