//  MovieViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 22/01/22.
//

import Foundation
import UIKit

@MainActor
class MovieViewModel: ObservableObject {
    @Published private(set) var phase: DataFetchPhase<[MovieSection]> = .empty
    private let service: NetworkService = NetworkService.shared
    var sections: [MovieSection] {
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
    
    private func fetchFromEndpoints(_ endpoint: [MovieEndpoints] = MovieEndpoints.allCases) async throws -> [MovieSection] {
        let results: [Result<MovieSection, Error>] = await withTaskGroup(of: Result<MovieSection, Error>.self) { group in
            for endpoint in endpoint {
                group.addTask { await self.fetchFromEndpoint(endpoint) }
            }
            var results = [Result<MovieSection, Error>]()
            for await result in group {
                results.append(result)
            }
            print(results)
            return results
        }
        var movieSections = [MovieSection]()
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
    
    private func fetchFromEndpoint(_ endpoint: MovieEndpoints) async -> Result<MovieSection, Error> {
        do {
            let movies = try await service.fetchMovies(from: endpoint)
            return .success(.init(results: movies, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
