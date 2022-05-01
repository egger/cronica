//
//  GenreDetailsViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import Foundation
import Combine

@MainActor class GenreDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var items: [Content]?
    private var id: Int = 0
    
    // MARK: Pagination Properties
    @Published var currentPage: Int = 0
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    
    init(id: Int) {
        self.id = id
        loadMoreItems()
    }
    
    func loadMoreItems() {
        currentPage += 1
        Task{
            do{
                try await fetch()
            }catch{
                // HANDLE ERROR
            }
        }
    }
    
    func fetch() async throws {
        let content = try? await service.fetchDiscover(sort: "popularity.desc", page: currentPage, genres: "\(self.id)")
        await MainActor.run(body: {
            if items == nil { items = [] }
            items?.append(contentsOf: content ?? [])
            endPagination = (items?.count ?? 0) > 100
            startPagination = false
        })
    }
}
