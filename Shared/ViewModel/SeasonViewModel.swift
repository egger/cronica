//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import Foundation

@MainActor class SeasonViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Season?> = .empty
    var season: Season? { phase.value ?? nil }
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let season = try await self.service.fetchSeason(id: id, season: season)
            phase = .success(season)
        } catch {
            phase = .failure(error)
        }
    }
}
