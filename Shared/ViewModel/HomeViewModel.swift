//
//  HomeViewModel.swift
//  Story
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
    
    func load() async {
        Task {
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
            DispatchQueue.main.async {
                withAnimation { self.isLoaded = true }
            }
            if recommendations.isEmpty {
                await fetchRecommendations()
            }
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
    
    // MARK: Recommendation System
    // This is a very simple recommendation system, it the recommendation endpoint from TMDb API
    // to fetch the recommendations from watched or favorite items, then it filters out
    // some content without image or that contains NSFW keywords.
    
    /// Get the items which recommendations will be based at, these items must be watched OR favorite.
    /// - Returns: Returns a shuffled array of WatchlistItems that matches the criteria of watched OR favorite.
    private func fetchBasedRecommendationItems() -> [WatchlistItem] {
        do {
            let context = PersistenceController.shared.container.newBackgroundContext()
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            let watchedPredicate = NSPredicate(format: "watched == %d", true)
            let favoritesPredicate = NSPredicate(format: "favorite == %d", true)
            request.predicate = NSCompoundPredicate(type: .or,
                                                    subpredicates: [watchedPredicate, favoritesPredicate])
            let list = try context.fetch(request)
            return list.shuffled()
        } catch {
            CronicaTelemetry.shared.handleMessage("\(error.localizedDescription)",
                                                  for: "HomeViewModel.fetchBasedRecommendationItems")
            return []
        }
    }
    
    /// Gets all the IDs from watched content saved on Core Data.
    private func fetchWatchedIDs() -> Set<String> {
        do {
            var watchedIds: Set<String> = []
            let context = PersistenceController.shared.container.newBackgroundContext()
            let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
            let watchedPredicate = NSPredicate(format: "watched == %d", true)
            request.predicate = NSCompoundPredicate(type: .or,
                                                    subpredicates: [watchedPredicate])
            let list = try context.fetch(request)
            if !list.isEmpty {
                for item in list {
                    watchedIds.insert(item.notificationID)
                }
            }
            return watchedIds
        } catch {
            return []
        }
    }
    
    private func fetchRecommendations() async {
        var recommendationsFetched = [ItemContent]()
        let itemsToRecommendFrom = fetchBasedRecommendationItems()
        let limitedItems = itemsToRecommendFrom.prefix(6)
        for item in limitedItems {
            let result = try? await service.fetchItems(from: "\(item.itemMedia.rawValue)/\(item.itemId)/recommendations")
            if let result {
                recommendationsFetched.append(contentsOf: result)
            }
        }
        let recommendations = await filterRecommendationsItems(recommendationsFetched)
        self.recommendations = recommendations.sorted { $0.itemPopularity > $1.itemPopularity }
        DispatchQueue.main.async {
            withAnimation { self.isLoadingRecommendations = false }
        }
    }
    
    /// Filters out recommendations from items without images and that matches NSFW keywords.
    /// - Parameter items: The items to be filtered.
    /// - Returns: The items filtered out.
    private func filterRecommendationsItems(_ items: [ItemContent]) async -> Set<ItemContent> {
        let watchedItems = fetchWatchedIDs()
        var result = Set<ItemContent>()
        for item in items {
            if item.posterPath != nil && item.backdropPath != nil {
                let contentKeywords = try? await service.fetchKeywords(type: item.itemContentMedia,
                                                                       id: item.id)
                if let contentKeywords {
                    var keywordsArray = [Int]()
                    let _: [()] = contentKeywords.map { item in
                        keywordsArray.append(item.id)
                    }
                    let containsNSFW = !Set(keywordsArray).isDisjoint(with: nsfwKeywords)
                    if !containsNSFW {
                        result.insert(item)
                    }
                } else {
                    result.insert(item)
                }
            }
        }
        let filteredWatched = result.filter { !watchedItems.contains($0.itemNotificationID) }
        return filteredWatched
    }
}

/// Theses keywords are used in some NSFW titles, this should be only used
/// for avoiding displaying such titles in recommendations lists, explore and search.
let nsfwKeywords = [155477, 230416, 190370, 158254, 159551, 301766]
