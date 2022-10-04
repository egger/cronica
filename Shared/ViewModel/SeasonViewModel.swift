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
    @Published var isItemInWatchlist: Bool = false
    
    func load(id: Int, season: Int, isInWatchlist: Bool) async {
        if Task.isCancelled { return }
        isItemInWatchlist = isInWatchlist
        withAnimation {
            isLoading = true
        }
        do {
            self.season = try await self.service.fetchSeason(id: id, season: season)
        } catch {
            TelemetryErrorManager.shared.handleErrorMessage(error.localizedDescription,
                                                            for: "SeasonViewModel.load()")
        }
        if !hasFirstLoaded {
            hasFirstLoaded.toggle()
        }
        withAnimation {
            isLoading = false
        }
    }
    
    func markSeasonAsWatched(id: Int) async {
        if let season {
            if let episodes = season.episodes {
                if !isItemInWatchlist {
                    await saveItemOnList(id: id)
                }
                for episode in episodes {
                    if !persistence.isEpisodeSaved(show: id, season: season.seasonNumber, episode: episode.id) {
                        persistence.updateEpisodeList(show: id, season: season.seasonNumber, episode: episode.id)
                    }
                }
            }
        }
    }
    
    func markThisAndPrevious(until id: Int, show: Int) async {
        if !isItemInWatchlist {
            await saveItemOnList(id: show)
        }
        if let season {
            if let episodes = season.episodes {
                for episode in episodes {
                    if !persistence.isEpisodeSaved(show: show, season: season.seasonNumber, episode: episode.id) {
                        persistence.updateEpisodeList(show: show, season: season.seasonNumber, episode: episode.id)
                    }
                    if episode.id == id {
                        return
                    }
                }
            }
        }
    }
    
    private func saveItemOnList(id: Int) async {
        let content = try? await network.fetchItem(id: id, type: .tvShow)
        if let content {
            persistence.save(content)
            isItemInWatchlist = true
        }
    }
}
