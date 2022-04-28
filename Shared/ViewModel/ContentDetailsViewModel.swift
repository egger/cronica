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

@MainActor class ContentDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    var content: Content? { phase.value ?? nil }
    let context: DataController = DataController.shared
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if phase.value == nil {
            phase = .empty
            do {
                let content = try await self.service.fetchContent(id: id, type: type)
                phase = .success(content)
            } catch {
                phase = .failure(error)
                TelemetryManager.send("DetailsViewModel_LoadError",
                                      with: ["ID/Error:":"\(id)/\(error.localizedDescription)"])
            }
        }
    }
    
    func update(markAsWatched watched: Bool?, markAsFavorite favorite: Bool?) {
        if let content = content {
            if let favorite = favorite {
                context.updateItem(content: content, isWatched: nil, isFavorite: favorite)
            }
            else if let watched = watched {
                context.updateItem(content: content, isWatched: watched, isFavorite: nil)
            }
            else {
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
    }
}
