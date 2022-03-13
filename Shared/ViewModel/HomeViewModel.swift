//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var moviePhase: DataFetchPhase<[ContentSection]> = .empty
    @Published private(set) var tvPhase: DataFetchPhase<[ContentSection]> = .empty
    @Published private(set) var trendingMovies: DataFetchPhase<[ContentResponse]> = .empty
    @Published private(set) var trendingTv: DataFetchPhase<[ContentResponse]> = .empty
    private let service: NetworkService = NetworkService.shared
    var moviesSections: [ContentSection] {
        moviePhase.value ?? []
    }
    var tvSections: [ContentSection] {
        tvPhase.value ?? []
    }
    var trendingMoviesSection: [ContentResponse] {
        trendingMovies.value ?? []
    }
    var trendingTvSection: [ContentResponse] {
        trendingTv.value ?? []
    }
    
    func loadSections() async {
        Task {
            await loadMovies()
            await loadTv()
        }
    }
    
    private func loadMovies() async {
        if Task.isCancelled {
            return
        }
        if case .success = moviePhase {
            return
        }
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
    
    private func loadTv() async {
        if Task.isCancelled {
            return
        }
        if case .success = tvPhase {
            return
        }
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
    
    private func loadTrendingMovies() async {
        if Task.isCancelled {
            return
        }
        if case .success = trendingMovies {
            return
        }
        trendingMovies = .empty
        do {
            //let trending = try await service.fetchContents(from: <#T##ContentEndpoints#>, type: <#T##MediaType#>)
        }
    }
    
    private func fetchEndpoints(_ endpoint: [ContentEndpoints] = ContentEndpoints.allCases, type: MediaType) async throws -> [ContentSection] {
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
    
    private func fetchFrom(_ endpoint: ContentEndpoints, type: MediaType) async -> Result<ContentSection, Error> {
        do {
            let section = try await service.fetchContents(from: endpoint, type: type)
            return .success(.init(results: section, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
