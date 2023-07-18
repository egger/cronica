//
//  CompanyDetailsViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import Foundation

@MainActor
class CompanyDetailsViewModel: ObservableObject {
    var page = 1
    @Published var items = [ItemContent]()
    @Published var startPagination = false
    @Published var endPagination = false
    @Published var isLoaded = false
    private let network = NetworkService.shared
    
    @MainActor
    func load(_ id: Int) async {
        do {
            let movies = try await network.fetchCompanyFilmography(type: .movie,
                                                                   page: page,
                                                                   company: id)
            let shows = try await network.fetchCompanyFilmography(type: .tvShow,
                                                                  page: page,
                                                                  company: id)
            let result = movies + shows
            if result.isEmpty {
                endPagination = true
                return
            } else {
                page += 1
            }
            items.append(contentsOf: result.sorted { $0.itemPopularity > $1.itemPopularity })
            if !startPagination { startPagination = true }
            if !isLoaded {
                await MainActor.run {
                    self.isLoaded = true
                }
            }
        } catch {
            if Task.isCancelled { return }
            let message = "Company ID: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "CompanyDetailsViewModel.load()")
        }
    }
}
