//
//  CastDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation

@MainActor class CastDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Person?> = .empty
    var person: Person? { phase.value ?? nil }
    var isLoaded: Bool = false
    
    func load(id: Int) async {
        if Task.isCancelled { return }
        if isLoaded != true {
            phase = .empty
            do {
                let person = try await self.service.fetchPerson(id: id)
                phase = .success(person)
                isLoaded = true
            } catch {
                phase = .failure(error)
            }
        }
    }
}
