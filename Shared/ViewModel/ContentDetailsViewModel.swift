//
//  ContentDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation

@MainActor
class ContentDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    var content: Content? {
        phase.value ?? nil
    }
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let content = try await self.service.fetchContent(id: id, type: type)
            phase = .success(content)
        } catch {
            phase = .failure(error)
        }
    }
}

