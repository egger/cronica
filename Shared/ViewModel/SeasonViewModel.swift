//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import Foundation

@MainActor
class SeasonViewModel: ObservableObject {
    private let service = NetworkService.shared
    private let persistence = PersistenceController.shared
    @Published var season: Season?
    @Published var isLoading: Bool = true
    private var hasFirstLoaded: Bool = false
    @Published var watchlistItem: WatchlistItem? = nil
    
    func load(id: Int, season: Int) async {
        if Task.isCancelled { return }
        isLoading = true
        self.season = try? await self.service.fetchSeason(id: id, season: season)
        if !hasFirstLoaded {
            hasFirstLoaded.toggle()
            if persistence.isItemSaved(id: id, type: .tvShow) {
                watchlistItem = persistence.fetch(for: WatchlistItem.ID(id))
            }
        }
        isLoading = false
    }
}
