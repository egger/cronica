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
    @Published var isLoaded: Bool = false
    
    func load() async {
        Task {
            if trending.isEmpty {
                do {
                    let result = try await service.fetchItems(from: "trending/all/day")
                    let filtered = result.filter { $0.itemContentMedia != .person }
                    trending = filtered
                } catch {
                    if Task.isCancelled { return }
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                                    for: "HomeViewModel.load()")
                }
            }
            if sections.isEmpty {
                let result = await self.fetchSections()
                sections.append(contentsOf: result)
            }
            withAnimation {
                isLoaded = true
            }
        }
    }
    
    func reload() {
        withAnimation { isLoaded = false }
        trending.removeAll()
        sections.removeAll()
        Task {
            await load()
        }
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
    
    /// Fetch an Endpoint value.
    /// - Parameter endpoint: The endpoint used for popular, upcoming, etc.
    /// - Returns: Return a ItemContentSection already populated with Endpoint value if that fetch is successful, otherwise it returns nil.
    private func fetch(from endpoint: Endpoints) async -> ItemContentSection? {
        do {
            let section = try await service.fetchItems(from: "\(endpoint.type.rawValue)/\(endpoint.rawValue)")
            return .init(results: section, endpoint: endpoint)
        } catch {
            if Task.isCancelled { return nil }
            let message = """
Can't load the endpoint \(endpoint.title), with error message: \(error.localizedDescription).
"""
            CronicaTelemetry.shared.handleMessage(message, for: "HomeViewModel.load()")
            return nil
        }
    }
}
