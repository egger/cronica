//
//  SeasonViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import Foundation

@MainActor class SeasonViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Season?> = .empty
    var season: Season? {
        phase.value ?? nil
    }
    
    func load(id: Int, seasonNumber: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let season = try await self.service.fetchSeason(id: id, season: seasonNumber)
            phase = .success(season)
        } catch {
            phase = .failure(error)
        }
    }
}
