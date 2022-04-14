//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import UserNotifications
import SwiftUI
import TelemetryClient

@MainActor class DetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    var content: Content? { phase.value ?? nil }
    let context: WatchlistController = WatchlistController.shared
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if phase.value == nil {
            phase = .empty
            do {
                let content = try await self.service.fetchContent(id: id, type: type)
                phase = .success(content)
            } catch {
                phase = .failure(error)
                TelemetryManager.send("DetailsViewModel_LoadError", with: ["ID:":"\(id)"])
            }
        }
    }
    
    func update() {
        if let content = content {
            if context.isItemInList(id: content.id) {
                let item = try? context.getItem(id: WatchlistItem.ID(content.id))
                if let item = item {
                    let identifier: String = "\(content.itemTitle)+\(content.id)"
                    if context.isNotificationScheduled(id: content.id) {
                        notification.removeNotification(identifier: identifier)
                    }
                    try? context.removeItem(id: item)
                }
            } else {
                context.saveItem(content: content, notify: content.itemCanNotify)
                if content.itemCanNotify {
                    notification.schedule(content: content)
                }
            }
        }
    }
    
    func itemCanNotify() -> Bool {
        if let item = content {
            if let date = item.itemTheatricalDate {
                if date > Date() {
                    return true
                }
            }
            if let date = item.nextEpisodeDate {
                if date > Date() {
                    return true
                }
            }
        }
        return false
    }
}
