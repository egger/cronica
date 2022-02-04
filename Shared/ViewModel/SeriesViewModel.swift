//
//  SeriesViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation
import UIKit

@MainActor
class SeriesViewModel: ObservableObject {
    @Published private(set) var phase: DataFetchPhase<[SeriesSection]> = .empty
    private let service: NetworkService = NetworkService.shared
    var sections: [SeriesSection] {
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
    
    private func fetchFromEndpoints(_ endpoints: [SeriesEndpoint] = SeriesEndpoint.allCases) async throws -> [SeriesSection] {
        let results: [Result<SeriesSection, Error>] = await withTaskGroup(of: Result<SeriesSection, Error>.self) { group in
            for endpoint in endpoints {
                group.addTask { await self.fetchEndpoint(endpoint) }
            }
            var results = [Result<SeriesSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var seriesSection = [SeriesSection]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let serieSection):
                seriesSection.append(serieSection)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if errors.count == results.count, let error = errors.first {
            throw error
        }
        
        return seriesSection.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchEndpoint(_ endpoint: SeriesEndpoint) async -> Result<SeriesSection, Error> {
        do {
            let series = try await service.fetchTvShows(from: endpoint)
            print(series)
            return .success(.init(result: series, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
