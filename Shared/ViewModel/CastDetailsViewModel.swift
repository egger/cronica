//
//  CastDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation

@MainActor class CastDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    let id: Int
    @Published private(set) var phase: DataFetchPhase<Person?> = .empty
    @Published var isLoaded: Bool = false
    var person: Person?
    @Published var credits: [ItemContent]?
    
    init(id: Int) {
        self.id = id
    }
    
    func load() async {
        if Task.isCancelled { return }
        if person == nil {
            do {
                person = try await self.service.fetchPerson(id: self.id)
                if let person {
                    let combinedCredits = person.combinedCredits?.cast?.filter { $0.itemIsAdult == false }
                    credits = combinedCredits?.sorted(by: { $0.itemPopularity > $1.itemPopularity })
                }
                isLoaded.toggle()
            } catch {
                phase = .failure(error)
                person = nil
                print(error.localizedDescription)
            }
        }
    }
}
