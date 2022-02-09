//
//  TvDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import Foundation

@MainActor
class TvDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<TvShow?> = .empty
    var tvShow: TvShow? {
        phase.value ?? nil
    }
    
    func loadTvShow(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let tvShow = try await self.service.fetchTvShow(id: id)
            print(tvShow)
            phase = .success(tvShow)
        } catch {
            phase = .failure(error)
        }
    }
}
