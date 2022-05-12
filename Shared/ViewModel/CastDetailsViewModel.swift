//
//  CastDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation
import TelemetryClient

@MainActor class CastDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Person?> = .empty
    var isLoaded: Bool = false
    var person: Person?
    
    func load(id: Int) async {
        if Task.isCancelled { return }
        if person == nil {
            do {
                person = try await self.service.fetchPerson(id: id)
                isLoaded = true
            } catch {
                phase = .failure(error)
                TelemetryManager.send("CastDetailsViewModel_loadError",
                                      with: ["ID:":"\(id)"])
            }
        }
    }
}
