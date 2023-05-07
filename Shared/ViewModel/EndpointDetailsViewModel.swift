//
//  EndpointDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

@MainActor
class EndpointDetailsViewModel: ObservableObject {
    @Published var items = [ItemContent]()
    private var page = 1
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    @Published var isLoading = true
    
    func loadMoreItems(for endpoint: Endpoints) async {
        do {
            let result = try await NetworkService.shared.fetchItems(from: "\(endpoint.type.rawValue)/\(endpoint.rawValue)", page: String(page))
            items.append(contentsOf: result)
            if !items.isEmpty {
                page += 1
                startPagination = false
            }
            if result.isEmpty { endPagination = true }
            withAnimation { isLoading = false }
        } catch {
            if Task.isCancelled { return }
        }
    }
}
