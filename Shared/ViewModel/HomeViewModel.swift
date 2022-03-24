//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation

@MainActor class HomeViewModel: ObservableObject {
    @Published private(set) var moviePhase: DataFetchPhase<[ContentSection]> = .empty
    @Published private(set) var tvPhase: DataFetchPhase<[ContentSection]> = .empty
    @Published private(set) var trendingPhase: DataFetchPhase<[Content]> = .empty
    private let service: NetworkService = NetworkService.shared
    var moviesSections: [ContentSection] {
        moviePhase.value ?? []
    }
    var tvSections: [ContentSection] {
        tvPhase.value ?? []
    }
    var trendingSection: [Content] {
        trendingPhase.value ?? []
    }
    
    func load() async {
        Task {
            if Task.isCancelled { return }
            if case .success = moviePhase { return }
            moviePhase = .empty
            do {
                let movieSections = try await fetchEndpoints(type: MediaType.movie)
                if Task.isCancelled { return }
                moviePhase = .success(movieSections)
            } catch {
                if Task.isCancelled { return }
                moviePhase = .failure(error)
            }
        }
        Task {
            if Task.isCancelled { return }
            if case .success = tvPhase { return }
            tvPhase = .empty
            do {
                let tvSections = try await fetchEndpoints(type: MediaType.tvShow)
                if Task.isCancelled { return }
                tvPhase = .success(tvSections)
            } catch {
                if Task.isCancelled { return }
                tvPhase = .failure(error)
            }
        }
        Task {
            if Task.isCancelled { return }
            if case .success = trendingPhase { return }
            trendingPhase = .empty
            do {
                let trending = try await self.service.fetchContents(from: "trending/all/week")
                if Task.isCancelled { return }
                let trendings = trending.filter { $0.itemContentMedia != .movie || $0.itemContentMedia != .tvShow}
                trendingPhase = .success(trendings)
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
                group.addTask { await self.fetchFrom(endpoint, type: type) }
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
        
        if errors.count == results.count, let error = errors.first {
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
