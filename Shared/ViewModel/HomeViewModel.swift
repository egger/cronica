//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation
import CoreData

@MainActor
class HomeViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var trendingItems: [ItemContent] = []
    @Published var sectionsItems: [ItemContentSection] = []
    
    func load() async {
        Task {
            if trendingItems.isEmpty {
                let result = try? await service.fetchContents(from: "trending/all/week")
                if let result {
                    let trending = result.filter { $0.itemContentMedia != .person }
                    trendingItems = trending
                }
            }
            if sectionsItems.isEmpty {
                let sections = await self.fetchSections()
                sectionsItems.append(contentsOf: sections)
            }
        }
    }
    
    func reload() async {
        trendingItems.removeAll()
        sectionsItems.removeAll()
        await load()
    }
    
    private func fetchSections() async -> [ItemContentSection] {
        let endpoints = Endpoints.allCases
        var sections = [ItemContentSection]()
        for endpoint in endpoints {
            let section = await fetch(from: endpoint)
            if let section {
                sections.append(section)
            }
        }
        return sections
    }
    
    private func fetch(from endpoint: Endpoints) async -> ItemContentSection? {
        let section = try? await service.fetchContents(from: "\(MediaType.movie.rawValue)/\(endpoint.rawValue)")
        if let section {
            return .init(results: section, endpoint: endpoint)
        }
        return nil
    }
    
    
}
