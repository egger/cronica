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
            let sortedItems = items.sorted(by: { $0.itemLastUpdateDate > $1.itemLastUpdateDate}).filter { $0.firstAirDate != nil }
			for item in sortedItems {
                let result = try? await network.fetchEpisode(tvID: item.id,
                                                             season: item.itemNextUpNextSeason,
                                                             episodeNumber: item.itemNextUpNextEpisode)
                if let result {
					let seasonNumber = result.seasonNumber ?? 0
                    let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                               season: seasonNumber,
                                                               episode: result.id)
                    var isReleased = result.isItemReleased
                    if result.airDate == nil {
                        let show = try? await network.fetchItem(id: item.itemId, type: .tvShow)
                        if show?.itemStatus == .ended { isReleased = true }
                    }
                    if isReleased && !isWatched {
                        let content = UpNextEpisode(id: result.id,
                                                    showTitle: item.itemTitle,
                                                    showID: item.itemId,
                                                    backupImage: item.backCompatibleCardImage,
                                                    episode: result,
                                                    sortedDate: item.itemLastUpdateDate)
                        
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
																				  season: Int(nextSeasonNumber),
                                                                                  episode: nextEpisode.id)
							let show = try? await network.fetchItem(id: item.itemId, type: .tvShow)
							let isReleased = show?.itemStatus == .ended ? true : nextEpisode.isItemReleased
                            if isReleased && !isNextEpisodeWatched {
                                let content = UpNextEpisode(id: nextEpisode.id,
                                                            showTitle: item.itemTitle,
                                                            showID: item.itemId,
                                                            backupImage: item.backCompatibleCardImage,
                                                            episode: nextEpisode,
                                                            sortedDate: item.itemLastUpdateDate)
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
                withAnimation(.easeInOut)  {
                    self.isLoaded = true
                }
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
            var isReleased = nextEpisode.isItemReleased
            if nextEpisode.airDate == nil {
                let showContent = try? await network.fetchItem(id: content.showID, type: .tvShow)
                if showContent?.itemStatus == .ended { isReleased = true }
            }
            if isReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: content.showTitle,
                                            showID: content.showID,
                                            backupImage: content.backupImage,
                                            episode: nextEpisode,
                                            sortedDate: Date())
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
				let resultSeasonNumber = result.seasonNumber ?? 0
                let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                           season: resultSeasonNumber,
                                                           episode: result.id)
                let isInEpisodeList = episodes.contains(where: { $0.episode.id == result.id })
                let isItemAlreadyLoadedInList = episodes.contains(where: { $0.showID == item.itemId })
                var isReleased = result.isItemReleased
                if result.airDate == nil {
                    let show = try? await network.fetchItem(id: item.itemId, type: .tvShow)
                    if show?.itemStatus == .ended { isReleased = true }
                }
                if isReleased && !isWatched && !isInEpisodeList {
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
                                                backupImage: item.backCompatibleCardImage,
                                                episode: result,
                                                sortedDate: item.itemLastUpdateDate)
                    
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
        var isReleased = nextEpisode.isItemReleased
        if nextEpisode.airDate == nil {
            let showContent = try? await network.fetchItem(id: content.showID, type: .tvShow)
            if showContent?.itemStatus == .ended { isReleased = true }
        }
        if isReleased {
            let content = UpNextEpisode(id: nextEpisode.id,
                                        showTitle: content.showTitle,
                                        showID: content.showID,
                                        backupImage: content.backupImage,
                                        episode: nextEpisode,
                                        sortedDate: Date())
            
            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.episodes.insert(content, at: 0)
                }
            }
        }
    }
}
