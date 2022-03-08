//
//  ContentDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

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
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let content = try await self.service.fetchContent(id: id, type: type)
            phase = .success(content)
            if context.isItemInList(id: content.id) {
                inWatchlist.toggle()
            }
            print("\(content.itemTitle) is added? \(inWatchlist)")
        } catch {
            phase = .failure(error)
        }
    }
    
    func add() {
        if !context.isItemInList(id: content!.id) {
            context.saveItem(content: content!, type: content!.media.watchlistInt, notify: false)
            inWatchlist.toggle()
            print("Added \(content!.itemTitle)")
        }
    }
    
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
