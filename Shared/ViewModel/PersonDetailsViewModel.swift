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
    private let persistence: PersistenceController = PersistenceController.shared
    let id: Int
    @Published var isLoaded: Bool = false
    @Published var person: Person?
    @Published var credits = [ItemContent]()
    @Published var errorMessage: String = "Error found, try again later."
    @Published var showErrorAlert: Bool = false
    @Published var query: String = ""
    @Published var isFavorite: Bool = false
    
    init(id: Int) {
        self.id = id
    }
    
    func load() async {
        if Task.isCancelled { return }
        if person == nil {
            do {
                person = try await self.service.fetchPerson(id: self.id)
                if let person {
                    isFavorite = persistence.isPersonSaved(id: person.id)
                    let combinedCredits = person.combinedCredits?.cast?.filter { $0.itemIsAdult == false }
                    if let combinedCredits {
                        if !combinedCredits.isEmpty {
                            let combined: Set = Set(combinedCredits)
                            credits = combined.sorted(by: { $0.itemPopularity > $1.itemPopularity })
                        }
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
    
    func updateFavorite() {
        if let person {
            if isFavorite {
                let item = persistence.fetch(person: PersonItem.ID(person.id))
                if let item {
                    persistence.delete(item)
                }
            } else {
                persistence.save(person)
            }
            withAnimation {
#if os(watchOS)
#else
                HapticManager.shared.lightHaptic()
#endif
                isFavorite.toggle()
            }
        }
    }
}
