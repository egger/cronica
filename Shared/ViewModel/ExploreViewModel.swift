//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class ExploreViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published var items = [ItemContent]()
    @AppStorage("exploreViewSelectedGenre") var selectedGenre: Int = 28
    @AppStorage("exploreViewSelectedMedia") var selectedMedia: MediaType = .movie
    @Published var selectedSortBy: DiscoverSortBy = .popularityDesc
    @Published var selectedWatchProviders = [String]()
    @Published var isLoaded: Bool = false
    @Published var showErrorDialog: Bool = false
    @AppStorage("exploreViewHideAddedItems") var hideAddedItems = false
    // MARK: Pagination Properties
    @Published var currentPage: Int = 0
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    @Published var restartFetch: Bool = false
    
    private func clearItems() {
        withAnimation {
            isLoaded = false
            items.removeAll()
        }
    }
    
    func hideItems() {
        let ids = fetchAllItemsIDs(selectedMedia)
        withAnimation {
            items.removeAll(where: { ids.contains($0.itemContentID)})
        }
    }
    
    func loadMoreItems() {
        if restartFetch {
            currentPage = 0
            startPagination = true
            clearItems()
            restartFetch = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.isLoaded = true
                }
            }
        }
        currentPage += 1 
        Task {
            await fetch()
        }
    }
    
    private func fetch() async {
        do {
            let result = try await service.fetchDiscover(type: selectedMedia,
                                                         page: currentPage,
                                                         genres: "\(selectedGenre)",
                                                         sort: selectedSortBy)
            if hideAddedItems {
                let ids = fetchAllItemsIDs(selectedMedia)
                items.append(contentsOf: result.filter { !ids.contains($0.itemContentID)})
            } else {
                items.append(contentsOf: result)
            }
            if currentPage == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        self.isLoaded = true
                    }
                }
            }
            if result.isEmpty { endPagination = true }
            startPagination = false
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "DiscoverViewModel.fetch()")
            showErrorDialog.toggle()
        }
    }
    
    private func fetchAllItemsIDs(_ media: MediaType) -> [String] {
        let persistence = PersistenceController.shared
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let typePredicate = NSPredicate(format: "contentType == %d", media.toInt)
        request.predicate = typePredicate
        do {
            let list = try persistence.container.viewContext.fetch(request)
            var ids = [String]()
            for item in list {
                ids.append(item.itemContentID)
            }
            return ids
        } catch {
            if Task.isCancelled { return [] }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "BackgroundManager.fetchAllItemsIDs()")
            return []
        }
    }
    
    // MARK: Genres array.
    let movies: [Genre] = [
        Genre(id: 28, name: NSLocalizedString("Action", comment: "")),
        Genre(id: 12, name: NSLocalizedString("Adventure", comment: "")),
        Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
        Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
        Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
        Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
        Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
        Genre(id: 10751, name: NSLocalizedString("Family", comment: "")),
        Genre(id: 14, name: NSLocalizedString("Fantasy", comment: "")),
        Genre(id: 36, name: NSLocalizedString("History", comment: "")),
        Genre(id: 27, name: NSLocalizedString("Horror", comment: "")),
        Genre(id: 10402, name: NSLocalizedString("Music", comment: "")),
        Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
        Genre(id: 10749, name: NSLocalizedString("Romance", comment: "")),
        Genre(id: 878, name: NSLocalizedString("Science Fiction", comment: "")),
        Genre(id: 53, name: NSLocalizedString("Thriller", comment: "")),
        Genre(id: 10752, name: NSLocalizedString("War", comment: ""))
    ]
    let shows: [Genre] = [
        Genre(id: 10759, name: NSLocalizedString("Action & Adventure", comment: "")),
        Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
        Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
        Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
        Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
        Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
        Genre(id: 10762, name: NSLocalizedString("Kids", comment: "")),
        Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
        Genre(id: 10765, name: NSLocalizedString("Sci-Fi & Fantasy", comment: ""))
    ]
}
