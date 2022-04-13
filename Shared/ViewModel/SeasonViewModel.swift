//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import Foundation
import os
import TelemetryClient

@MainActor class SeasonViewModel: ObservableObject {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SeasonViewModel.self)
    )
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Season?> = .empty
    var season: Season? { phase.value ?? nil }
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        if phase.value == nil {
            phase = .empty
            do {
                let season = try await self.service.fetchSeason(id: id, season: season)
                phase = .success(season)
            } catch {
                phase = .failure(error)
                TelemetryManager.send("SeasonViewModel_loadError", with: ["ID/Season:":"\(id)/\(season)"])
            }
        }
    }
}
