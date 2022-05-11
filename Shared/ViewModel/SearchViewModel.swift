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
    @Published private(set) var phase: DataFetchPhase<[Content]> = .empty
    private var cancellable = Set<AnyCancellable>()
    private var service: NetworkService = NetworkService.shared
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var searchItems: [Content] { phase.value ?? [] }
    @Published var currentPage: Int = 1
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    @Published var items: Content?
    
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
    
    func loadMoreItems() {
        currentPage += 1
        Task {
            //let items = try? await service.search(query: trimmedQuery, page: "\(currentPage)")
            //searchItems.append(contentsOf: items ?? [])
        }
    }
    
    func search(query: String) async {
        currentPage = 1
        if Task.isCancelled { return }
        phase = .empty
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return
        }
        do {
            let searchItems = try await service.search(query: trimmedQuery, page: "\(currentPage)")
            if Task.isCancelled { return }
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .success(searchItems)
        } catch {
            if Task.isCancelled { return }
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .failure(error)
        }
    }
}
