//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var trending: [ItemContent] = []
    @Published var sections: [ItemContentSection] = []
    
    func load() async {
        Task {
            if trending.isEmpty {
                let result = try? await service.fetchContents(from: "trending/all/week")
                if let result {
                    let filtered = result.filter { $0.itemContentMedia != .person }
                    trending = filtered
                }
            }
            if sections.isEmpty {
                let result = await self.fetchSections()
                sections.append(contentsOf: result)
            }
        }
    }
    
    func reload() async {
        withAnimation {
            trending.removeAll()
            sections.removeAll()
        }
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
    
    private func fetchRecommendationFromPerson() -> [String: [ItemContent]]? {
        return nil
    }
}
