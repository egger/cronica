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
    @Published var trendingItems: [ItemContent]?
    @Published var sectionsItems: [ItemContentSection] = []
    
    func load() async {
        Task {
            if trendingItems == nil {
                let result = try? await service.fetchContents(from: "trending/all/week")
                if let result {
                    let trending = result.filter { $0.itemContentMedia != .person }
                    trendingItems = trending
                }
            }
            if sectionsItems.isEmpty {
                let sections = await self.fetchEndpoints()
                if let sections {
                    sectionsItems.append(contentsOf: sections)
                }
            }
        }
    }
    
    private func fetchEndpoints(_ endpoints: [Endpoints] = Endpoints.allCases) async -> [ItemContentSection]? {
        let results: [Result<ItemContentSection, Error>] = await withTaskGroup(of: Result<ItemContentSection, Error>.self) { group in
            for endpoint in endpoints {
                group.addTask {
                    await self.fetchFrom(endpoint, media: .movie)
                }
            }
            var results = [Result<ItemContentSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var sections = [ItemContentSection]()
        
        results.forEach { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let section):
                sections.append(section)
            }
        }
        
        return sections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFrom(_ endpoint: Endpoints, media: MediaType) async -> Result<ItemContentSection, Error> {
        let section = try? await service.fetchContents(from: "\(media.rawValue)/\(endpoint.rawValue)")
        if let section {
            return .success(.init(results: section, endpoint: endpoint))
        }
        return .failure(NetworkError.invalidResponse)
    }
}
