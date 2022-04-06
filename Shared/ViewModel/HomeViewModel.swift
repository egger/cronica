//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation

@MainActor class HomeViewModel: ObservableObject {
    @Published private(set) var trendingPhase: DataFetchPhase<[Content]?> = .empty
    @Published private(set) var phase: DataFetchPhase<[ContentSection]?> = .empty
    private let service: NetworkService = NetworkService.shared
    var trendingSection: [Content]? {
        trendingPhase.value ?? nil
    }
    var sections: [ContentSection]? {
        phase.value ?? nil
    }
    
    func load() async {
        Task {
            if Task.isCancelled { return }
            if case .success = phase { return }
            phase = .empty
            do {
                var items: [ContentSection] = []
                let movies = try await self.fetchEndpoints(type: .movie)
                let shows = try await self.fetchEndpoints(type: .tvShow)
                if Task.isCancelled { return }
                for movie in movies {
                    items.append(movie)
                }
                for show in shows {
                    items.append(show)
                }
                phase = .success(movies)
            } catch {
                if Task.isCancelled { return }
                phase = .failure(error)
            }
            if case .success = trendingPhase { return }
            trendingPhase = .empty
            do {
                let trendingContent = try await self.service.fetchContents(from: "trending/all/week")
                let trending = trendingContent.filter { $0.itemContentMedia != .person }
                trendingPhase = .success(trending)
            } catch {
                if Task.isCancelled { return }
                trendingPhase = .failure(error)
            }
        }
    }
    
    private func fetchEndpoints(_ endpoint: [Endpoints] = Endpoints.allCases,
                                type: MediaType) async throws -> [ContentSection] {
        let results: [Result<ContentSection, Error>] = await withTaskGroup(of: Result<ContentSection, Error>.self) { group in
            for endpoint in endpoint {
                if type == .movie && endpoint != Endpoints.onTheAir {
                    group.addTask { await self.fetchFrom(endpoint, type: type) }
                }
                else if type == .tvShow && endpoint == Endpoints.onTheAir {
                    group.addTask { await self.fetchFrom(endpoint, type: type) }
                }
            }
            var results = [Result<ContentSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var sections = [ContentSection]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let section):
                sections.append(section)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if errors.count == results.count,
           let error = errors.first {
            throw error
        }
        
        return sections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFrom(_ endpoint: Endpoints, type: MediaType) async -> Result<ContentSection, Error> {
        do {
            let section = try await service.fetchContents(from: "\(type.rawValue)/\(endpoint.rawValue)")
            return .success(.init(results: section, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
