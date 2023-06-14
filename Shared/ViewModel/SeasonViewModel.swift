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
            let message = "Season \(season), show: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "SeasonViewModel.load.failed")
            DispatchQueue.main.async {
                withAnimation { self.isLoading = false }
            }
        }
    }
}
