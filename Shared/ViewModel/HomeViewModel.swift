//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation
import CoreData
import SwiftUI
import TelemetryClient

@MainActor
class HomeViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var trending: [ItemContent] = []
    @Published var sections: [ItemContentSection] = []
    @Published var isLoaded: Bool = false
    
    func load() async {
        Task {
            if trending.isEmpty {
                let result = try? await service.fetchItems(from: "trending/all/week")
                if let result {
                    let filtered = result.filter { $0.itemContentMedia != .person }
                    trending = filtered
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
#if targetEnvironment(simulator)
#else
        TelemetryManager.send("HomeViewModel.reload()")
#endif
        HapticManager.shared.lightHaptic()
        withAnimation { isLoaded = false }
        updateWatchlist()
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoaded = false
            }
        }
    }
    
    private func updateWatchlist() {
        DispatchQueue.global(qos: .background).async {
            let background = BackgroundManager()
            background.handleAppRefreshContent()
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
#if targetEnvironment(simulator)
            print("Error: HomeViewModel.fetch with error-endpoint: \(error.localizedDescription)-\(endpoint as Any).")
#else
            TelemetryManager.send("HomeViewModel.fetch(from endpoint: Endpoints)", with: ["error":"\(error.localizedDescription)"])
#endif
            return nil
        }
    }
}
