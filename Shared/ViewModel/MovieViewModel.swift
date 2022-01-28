//  MovieViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 22/01/22.
//

import Foundation
import UIKit

@MainActor
class MovieViewModel: ObservableObject {
    @Published private(set) var phase: DataFetchPhase<[Section]> = .empty
    private let service: NetworkService = NetworkService.shared
    var sections: [Section] {
        phase.value ?? []
    }
    
    func loadAllEndpoints() async {
        if Task.isCancelled {
            return
        }
        if case .success = phase {
            return
        }

        phase = .empty
        
        do {
            let sections = try await fetchFromEndpoints()
            if Task.isCancelled { return }
            phase = .success(sections)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
    private func fetchFromEndpoints(_ endpoint: [MovieEndpoints] = MovieEndpoints.allCases) async throws -> [Section] {
        let results: [Result<Section, Error>] = await withTaskGroup(of: Result<Section, Error>.self) { group in
            for endpoint in endpoint {
                group.addTask { await self.fetchFromEndpoint(endpoint) }
            }
            var results = [Result<Section, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var movieSections = [Section]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let movieSection):
                movieSections.append(movieSection)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if errors.count == results.count, let error = errors.first {
            throw error
        }
        
        return movieSections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFromEndpoint(_ endpoint: MovieEndpoints) async -> Result<Section, Error> {
        do {
            let movies = try await service.fetchMovies(from: endpoint)
            return .success(.init(movies: movies, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
