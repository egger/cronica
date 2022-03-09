//
//  ContentDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation

@MainActor
class ContentDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    var content: Content? {
        phase.value ?? nil
    }
    let context: DataController = DataController.shared
    @Published var inWatchlist: Bool = false
    
    /// Loads the content on Content model.
    /// - Parameters:
    ///   - id: The ID for the given title.
    ///   - type: Loads the proper content.
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let content = try await self.service.fetchContent(id: id, type: type)
            phase = .success(content)
            if context.isItemInList(id: content.id) {
                inWatchlist.toggle()
            }
            print("Is \(content.itemTitle) added? \(inWatchlist)")
        } catch {
            phase = .failure(error)
        }
    }
    
    /// Adds the item to Watchlist.
    /// - Parameter notify: Wherever is possible to notify user when a item is released.
    func add(notify: Bool = false) {
        if !context.isItemInList(id: content!.id) {
            context.saveItem(content: content!, type: content!.itemContentMedia.watchlistInt, notify: notify)
            inWatchlist.toggle()
            print("Added \(content!.itemTitle)")
        }
    }
    
    /// Removes the item from Watchlist.
    func remove() {
        if context.isItemInList(id: content!.id) {
            do {
                let item = try context.getItem(id: WatchlistItem.ID(content!.id))
                try context.removeItem(id: item)
                inWatchlist.toggle()
                print("Removed \(content!.itemTitle)")
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
    }
}
