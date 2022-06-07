//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import Foundation
import TelemetryClient

@MainActor class SeasonViewModel: ObservableObject {
    private let service = NetworkService.shared
    @Published var season: Season?
    @Published var isLoading: Bool = true    
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        isLoading = true
        self.season = try? await self.service.fetchSeason(id: id, season: season)
        isLoading = false
    }
}
