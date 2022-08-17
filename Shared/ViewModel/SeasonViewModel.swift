//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import SwiftUI

@MainActor
class SeasonViewModel: ObservableObject {
    private let service = NetworkService.shared
    private let persistence = PersistenceController.shared
    private let network = NetworkService.shared
    private var hasFirstLoaded: Bool = false
    @Published var season: Season?
    @Published var isLoading: Bool = true
    @Published var watchlistItem: WatchlistItem?
    @Published var isItemInWatchlist: Bool = false
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        withAnimation {
            isLoading = true
        }
        self.season = try? await self.service.fetchSeason(id: id, season: season)
        if !hasFirstLoaded {
            hasFirstLoaded.toggle()
            if persistence.isItemSaved(id: id, type: .tvShow) {
                isItemInWatchlist = true
                watchlistItem = persistence.fetch(for: WatchlistItem.ID(id))
            }
        }
        withAnimation {
            isLoading = false
        }
    }
    
    func markSeasonAsWatched(id: Int) async {
        HapticManager.shared.lightHaptic()
        if let season {
            if let episodes = season.episodes {
                if !isItemInWatchlist {
                    let content = try? await network.fetchContent(id: id, type: .tvShow)
                    if let content {
                        persistence.save(content)
                    }
                }
                for episode in episodes {
                    if !persistence.isEpisodeSaved(show: id, season: season.seasonNumber, episode: episode.id) {
                        persistence.updateEpisodeList(show: id, season: season.seasonNumber, episode: episode.id)
                    }
                }
            }
        }
    }
}
