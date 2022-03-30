//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import UserNotifications

@MainActor class DetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    @Published private(set) var seasonPhase: DataFetchPhase<Season?> = .empty
    var content: Content? { phase.value ?? nil }
    var season: Season? { seasonPhase.value ?? nil }
    let context: DataController = DataController.shared
    //@Published var notificationScheduled: Bool = false
   
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let content = try await self.service.fetchContent(id: id, type: type)
            phase = .success(content)
        } catch {
            phase = .failure(error)
        }
    }
    
    func loadSeason(id: Int, seasonNumber: Int) async {
        if Task.isCancelled { return }
        seasonPhase = .empty
        do {
            let season = try await self.service.fetchSeason(id: id, season: seasonNumber)
            seasonPhase = .success(season)
        } catch {
            seasonPhase = .failure(error)
        }
    }
    
    func addItem(notify: Bool = false) {
        if let content = content {
            if !context.isItemInList(id: content.id) {
                context.saveItem(content: content, type: content.itemContentMedia.watchlistInt, notify: notify)
            }
        }
    }
    
    func removeItem() {
        if let content = content {
            if context.isItemInList(id: content.id) {
                let item = try? context.getItem(id: WatchlistItem.ID(content.id))
                if let item = item {
                    try? context.removeItem(id: item)
                }
            }
        }
    }
    
    func scheduleNotification() {
        if let content = content {
            self.notification.scheduleNotification(content: content)
        }
    }
}
