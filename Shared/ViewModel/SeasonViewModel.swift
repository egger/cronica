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
    @Published var season: Season?
    @Published var isLoading: Bool = true    
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        do {
            isLoading = true
            self.season = try await self.service.fetchSeason(id: id, season: season)
            isLoading = false
        } catch {
            TelemetryManager.send("SeasonViewModel_loadError",
                                  with: ["ID-Season-Error":"ID:\(id)-Season:\(season)-Error:\(error.localizedDescription)."])
        }
    }
}
