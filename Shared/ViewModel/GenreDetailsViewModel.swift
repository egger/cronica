//
//  GenreDetailsViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import Foundation
import Combine
import TelemetryClient

@MainActor class GenreDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var items: [Content]?
    private var id: Int = 0
    private var type: MediaType = .movie
    // MARK: Pagination Properties
    @Published var currentPage: Int = 0
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    
    init(id: Int, type: MediaType) {
        self.id = id
        self.type = type
    }
    
    func loadMoreItems() {
        currentPage += 1
        Task {
            do {
                try await fetch()
            } catch {
                TelemetryManager.send("loadMoreItems_GenreDetailsViewModel",
                                      with: ["Error":"\(error.localizedDescription)"])
            }
        }
    }
    
    private func fetch() async throws {
        let content = try? await service.fetchDiscover(type: type,
                                                       sort: "popularity.desc",
                                                       page: currentPage,
                                                       genres: "\(self.id)")
        await MainActor.run(body: {
            if items == nil { items = [] }
            items?.append(contentsOf: content ?? [])
            endPagination = currentPage == 1000
            startPagination = false
        })
    }
    
    func addItem(id: Int) {
        
    }
}
