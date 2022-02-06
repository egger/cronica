//
//  CastViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation

@MainActor
class CastViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Cast?> = .empty
    var cast: Cast? {
        phase.value ?? nil
    }
    
    func loadCast(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let cast = try await self.service.fetchCast(id: id)
            phase = .success(cast)
        } catch {
            phase = .failure(error)
        }
    }
}
