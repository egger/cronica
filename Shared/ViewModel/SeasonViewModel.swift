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
    private let persistence = PersistenceController.shared
    private let network = NetworkService.shared
    private var hasFirstLoaded = false
    @Published var season: Season?
    @Published var isLoading = true
    @Published var isItemInWatchlist = false
    
    func load(id: Int, season: Int) async {
        do {
            if Task.isCancelled { return }
            DispatchQueue.main.async {
                withAnimation { self.isLoading = true }
            }
            self.season = try await self.network.fetchSeason(id: id, season: season)
            DispatchQueue.main.async {
                withAnimation { self.isLoading = false }
            }
        } catch {
            if Task.isCancelled { return }
            let message = "Season \(season), id: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "SeasonViewModel.load.failed")
            DispatchQueue.main.async {
                withAnimation { self.isLoading = false }
            }
        }
    }
    
    func markSeasonAsWatched(id: Int) {
        guard let season, let episodes = season.episodes else { return }
        for episode in episodes {
            if !persistence.isEpisodeSaved(show: id, season: season.seasonNumber, episode: episode.id) {
                persistence.updateEpisodeList(show: id, season: season.seasonNumber, episode: episode.id)
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
                    if episode.id == id { return }
                }
            }
        }
    }
    
    private func saveItemOnList(id: Int) async {
        do {
            let content = try await network.fetchItem(id: id, type: .tvShow)
            persistence.save(content)
            isItemInWatchlist = true
            if content.itemCanNotify && content.itemFallbackDate.isLessThanTwoMonthsAway() {
                NotificationManager.shared.schedule(content)
            }
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "SeasonViewModel.saveItemOnList.failed")
        }
    }
}
