//
//  UpNextViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 17/07/23.
//

import SwiftUI

@MainActor
class UpNextViewModel: ObservableObject {
    @Published var isLoaded = false
    @Published var episodes = [UpNextEpisode]()
    @Published var isWatched = false
    @Published var scrollToInitial = false
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    
    func load(_ items: FetchedResults<WatchlistItem>) async {
        if !isLoaded {
            for item in items {
                let result = try? await network.fetchEpisode(tvID: item.id,
                                                             season: item.itemNextUpNextSeason,
                                                             episodeNumber: item.itemNextUpNextEpisode)
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
                        
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                self.episodes.append(content)
                            }
                        }
                    } else if isWatched {
                        let nextSeasonNumber = item.seasonNumberUpNext + 1
                        let nextEpisode = try? await network.fetchEpisode(tvID: item.id,
                                                                          season: nextSeasonNumber,
                                                                          episodeNumber: 1)
                        if let nextEpisode {
                            let isNextEpisodeWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                                                  season: nextEpisode.itemSeasonNumber,
                                                                                  episode: nextEpisode.id)
                            if nextEpisode.isItemReleased && !isNextEpisodeWatched {
                                let content = UpNextEpisode(id: nextEpisode.id,
                                                            showTitle: item.itemTitle,
                                                            showID: item.itemId,
                                                            backupImage: item.image,
                                                            episode: nextEpisode)
                                await MainActor.run {
                                    withAnimation(.easeInOut) {
                                        self.episodes.append(content)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            await MainActor.run {
                withAnimation { self.isLoaded = true }
            }
        }
    }
    
    func reload(_ items: FetchedResults<WatchlistItem>) async {
        withAnimation { self.isLoaded = false }
        await MainActor.run {
            withAnimation(.easeInOut) {
                self.episodes.removeAll()
            }
        }
        Task { await load(items) }
    }
    
    func handleWatched(_ content: UpNextEpisode?) async {
        guard let content else { return }
        let helper = EpisodeHelper()
        let nextEpisode = await helper.fetchNextEpisode(for: content.episode, show: content.showID)
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: content.showTitle,
                                            showID: content.showID,
                                            backupImage: content.backupImage,
                                            episode: nextEpisode)
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        self.episodes.insert(content, at: 0)
                        self.scrollToInitial = true
                    }
                }
            }
        }
        await MainActor.run {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
            }
        }
    }
    
    func checkForNewEpisodes(_ items: FetchedResults<WatchlistItem>) async {
        for item in items {
            let result = try? await network.fetchEpisode(tvID: item.id,
                                                         season: item.seasonNumberUpNext,
                                                         episodeNumber: item.nextEpisodeNumberUpNext)
            if let result {
                let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                           season: result.itemSeasonNumber,
                                                           episode: result.id)
                let isInEpisodeList = episodes.contains(where: { $0.episode.id == result.id })
                let isItemAlreadyLoadedInList = episodes.contains(where: { $0.showID == item.itemId })
                
                if result.isItemReleased && !isWatched && !isInEpisodeList {
                    if isItemAlreadyLoadedInList {
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                self.episodes.removeAll(where: { $0.showID == item.itemId })
                            }
                        }
                    }
                    let content = UpNextEpisode(id: result.id,
                                                showTitle: item.itemTitle,
                                                showID: item.itemId,
                                                backupImage: item.image,
                                                episode: result)
                    
                    await MainActor.run {
                        withAnimation(.easeInOut) {
                            self.episodes.insert(content, at: 0)
                        }
                    }
                }
            }
        }
        
    }
    
    func markAsWatched(_ content: UpNextEpisode) async {
        let contentId = "\(content.showID)@\(MediaType.tvShow.toInt)"
        let item = persistence.fetch(for: contentId)
        guard let item else { return }
        persistence.updateWatchedEpisodes(for: item, with: content.episode)
        await MainActor.run {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
            }
        }
        HapticManager.shared.successHaptic()
        let nextEpisode = await EpisodeHelper().fetchNextEpisode(for: content.episode, show: content.showID)
        guard let nextEpisode else { return }
        persistence.updateUpNext(item, episode: nextEpisode)
        if nextEpisode.isItemReleased {
            let content = UpNextEpisode(id: nextEpisode.id,
                                        showTitle: content.showTitle,
                                        showID: content.showID,
                                        backupImage: content.backupImage,
                                        episode: nextEpisode)
            
            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.episodes.insert(content, at: 0)
                }
            }
        }
    }
}
