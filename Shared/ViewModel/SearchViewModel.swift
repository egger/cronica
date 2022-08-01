//
//  SearchViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var phase: DataFetchPhase<[ItemContent]> = .empty
    @Published var searchSuggestions = [SearchSuggestionItem]()
    private var cancellable = Set<AnyCancellable>()
    private var service: NetworkService = NetworkService.shared
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var searchItems: [ItemContent] { phase.value ?? [] }
    
    func observe() {
        guard cancellable.isEmpty else { return }
        $query
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sink { [weak self] _ in
                self?.phase = .empty
            }
            .store(in: &cancellable)
        $query
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { query in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.search(query: query)
                }
            }
            .store(in: &cancellable)
    }
    
    func fetchSuggestions() async {
        if searchSuggestions.isEmpty {
            let result = try? await service.fetchContents(from: "trending/all/week")
            if let result {
                let sorted = result.shuffled()
                while searchSuggestions.count <= 8 {
                    searchSuggestions.append(SearchSuggestionItem.init(suggestion: sorted[searchSuggestions.count].itemTitle ))
                }
            }
        }
    }
    
    func search(query: String) async {
        if Task.isCancelled { return }
        phase = .empty
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return
        }
        do {
            let searchItems = try await service.search(query: trimmedQuery, page: "1")
            if Task.isCancelled { return }
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .success(searchItems.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
        } catch {
            if Task.isCancelled { return }
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .failure(error)
        }
    }
}

struct SearchSuggestionItem: Identifiable {
    var id = UUID()
    let suggestion: String
}
