//
//  PersonDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation
import SwiftUI

@MainActor
class PersonDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    let id: Int
    @Published var isLoaded: Bool = false
    @Published var person: Person?
    @Published var credits: [ItemContent]?
    @Published var errorMessage: String?
    
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
                    if combinedCredits != nil && !combinedCredits.isEmpty {
                        let combined: Set = Set(combinedCredits!)
                        credits = combined.sorted(by: { $0.itemPopularity > $1.itemPopularity })
                    }
                }
                withAnimation {
                    isLoaded.toggle()
                }
            } catch {
                person = nil
                errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
    }
}
