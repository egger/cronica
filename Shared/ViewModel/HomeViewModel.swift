//
//  HomeViewModel.swift
//  Cronica
//
//  Created by Alexandre Madeira on 02/03/22.
//

import CoreData
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var trending = [ItemContent]()
    @Published var sections = [ItemContentSection]()
    @Published var recommendations = [ItemContent]()
    @Published var isLoaded = false
    @Published var isLoadingRecommendations = true
    
    // new feature test
    @Published var nextYearMovies: [[ItemContent]:YearEndpoint]?
    @Published var yearMovies = [ItemContent]()
    
    func fetchYearMovies() async {
        let year = try? await service.fetchYearContent(year: "2024", type: .movie)
        guard let year else { return }
        yearMovies.append(contentsOf: year)
    }
    
    /// Loads data for the home screen asynchronously, including trending items, sections, and recommendations.
    func load() async {
        if trending.isEmpty {
            do {
                let result = try await service.fetchItems(from: "trending/all/day")
                let filtered = result.filter { $0.itemContentMedia != .person }
                trending = filtered
            } catch {
                if Task.isCancelled { return }
                let message = "Can't load trending/all/day, error: \(error.localizedDescription)"
                CronicaTelemetry.shared.handleMessage(message, for: "HomeViewModel.load()")
            }
        }
        if sections.isEmpty {
            let result = await self.fetchSections()
            sections.append(contentsOf: result)
        }
        await MainActor.run {
            withAnimation { self.isLoaded = true }
        }
        if recommendations.isEmpty {
            await fetchRecommendations()
        }
        
        if yearMovies.isEmpty {
            await fetchYearMovies()
        }
    }
    
    func reload() {
        withAnimation {
            isLoaded = false
            isLoadingRecommendations = true
        }
        trending.removeAll()
        sections.removeAll()
        recommendations.removeAll()
        Task { await load() }
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
            let filtered = section.filter { $0.backdropPath != nil && $0.posterPath != nil }
            return .init(results: filtered, endpoint: endpoint)
        } catch {
            if Task.isCancelled { return nil }
            CronicaTelemetry.shared.handleMessage(
                "Can't load the endpoint \(endpoint.title), with error message: \(error.localizedDescription)",
                for: "HomeViewModel.load()"
            )
            return nil
        }
    }
    
    // MARK: Recommendation System
    // This is a very simple recommendation system, it the recommendation endpoint from TMDb API
    // to fetch the recommendations from watched or favorite items, then it filters out
    // some content without image or that contains NSFW keywords.
    
    /// Get the items which recommendations will be based at, these items must be watched OR favorite.
    /// - Returns: Returns a shuffled array of WatchlistItems that matches the criteria of watched OR favorite.
    private func fetchBasedRecommendationItems() -> [WatchlistItem] {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let watchedPredicate = NSPredicate(format: "watched == %d", true)
        let watchingPredicate = NSPredicate(format: "isWatching == %d", true)
        request.predicate = NSCompoundPredicate(type: .or, subpredicates: [watchingPredicate, watchedPredicate])
        guard let list = try? context.fetch(request) else { return [] }
        let items = list.shuffled().prefix(3)
        return items.shuffled()
    }
    
    /// Gets all the IDs from watched content saved on Core Data.
    private func fetchWatchedIDs() -> Set<String> {
        do {
            var watchedIds: Set<String> = []
            let context = PersistenceController.shared.container.newBackgroundContext()
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            let watchedPredicate = NSPredicate(format: "watched == %d", true)
            let watchingPredicate = NSPredicate(format: "isWatching == %d", true)
            request.predicate = NSCompoundPredicate(type: .or,
                                                    subpredicates: [watchedPredicate, watchingPredicate])
            let list = try context.fetch(request)
            if !list.isEmpty {
                for item in list {
                    watchedIds.insert(item.itemContentID)
                }
            }
            return watchedIds
        } catch {
            return []
        }
    }
    
    private func fetchRecommendations() async {
        var recommendations = [ItemContent]()
        let itemsWatched = fetchBasedRecommendationItems()
        var itemsToFetchFrom = [[Int:MediaType]]()
        for item in itemsWatched {
            itemsToFetchFrom.append([item.itemId:item.itemMedia])
        }
        for item in itemsToFetchFrom {
            let results = await getRecommendations(for: item)
            if let results {
                for result in results {
                    if !recommendations.contains(result) {
                        recommendations.append(result)
                    }
                }
            }
        }
        let content = await filterRecommendationsItems(recommendations)
        self.recommendations = content.sorted { $0.itemPopularity > $1.itemPopularity }
        await MainActor.run {
            withAnimation { self.isLoadingRecommendations = false }
        }
    }
    
    private func getRecommendations(for item: [Int:MediaType]) async -> [ItemContent]? {
        guard let (id, type) = item.first else { return nil }
        let result = try? await service.fetchItems(from: "\(type.rawValue)/\(id)/recommendations")
        return result
    }
    
    /// Filters out recommendations from items without images and that matches NSFW keywords.
    /// - Parameter items: The items to be filtered.
    /// - Returns: The items filtered out.
    private func filterRecommendationsItems(_ items: [ItemContent]) async -> Set<ItemContent> {
        let watchedItems = fetchWatchedIDs()
        var result = Set<ItemContent>()
        for item in items {
            if item.posterPath != nil, item.backdropPath != nil {
                result.insert(item)
            }
        }
        let filteredWatched = result.filter { !watchedItems.contains($0.itemContentID) }
        return filteredWatched
    }
}

/// Theses keywords are used in some NSFW titles, this should be only used
/// for avoiding displaying such titles in recommendations lists, explore and search.
let nsfwKeywords = [155477, 230416, 190370, 158254, 159551, 301766]


struct YearEndpoint: Identifiable, Hashable, Codable {
    let id: UUID
    let year: String
}
