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
    private var service: NetworkService = NetworkService.shared
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var page = 1
    @Published var items = [ItemContent]()
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    var stage: SearchStage = .none
    
    func search(_ query: String) async {
        if Task.isCancelled { return }
        if query.isEmpty {
            startPagination = false
            withAnimation {
                items.removeAll()
            }
            stage = .none
            return
        }
        stage = .searching
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        do {
            if Task.isCancelled {
                stage = .none
                return
            }
            try await Task.sleep(nanoseconds: 300_000_000)
            if !items.isEmpty {
                items.removeAll()
            }
            // restart pagination values
            page = 1
            endPagination = false
            let result = try await service.search(query: trimmedQuery, page: "1")
            page += 1
            items.append(contentsOf: result.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
            if self.items.isEmpty {
                stage = .empty
                return
            }
            stage = .success
            startPagination = true
        } catch {
            if Task.isCancelled { return }
            stage = .failure
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                            for: "SearchViewModel.search()")
        }
    }
    
    func loadMoreItems() {
        if Task.isCancelled { return }
        if items.isEmpty { return }
        if endPagination { return }
        if Task.isCancelled { return }
        Task {
            do {
                let result = try await service.search(query: trimmedQuery, page: "\(page)")
                if result.isEmpty { endPagination.toggle() }
                withAnimation {
                    self.items.append(contentsOf: result.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
                }
                self.page += 1
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(
                    error.localizedDescription,
                    for: "ItemContentViewModel.loadMoreItems()"
                )
            }
        }
    }
}

enum SearchStage: String {
    var id: String { rawValue }
    case none, failure, empty, success, searching
}

