//
//  TVDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import Foundation

@MainActor
class TVDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<TVShow?> = .empty
    var tvShow: TVShow? {
        phase.value ?? nil
    }
    
    func load(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let tvShow = try await self.service.fetchTvShow(id: id)
            phase = .success(tvShow)
        } catch {
            phase = .failure(error)
        }
    }
}
