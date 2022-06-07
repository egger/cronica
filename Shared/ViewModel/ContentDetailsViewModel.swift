//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  

import Foundation
import SwiftUI
import TelemetryClient

@MainActor class ContentDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<ItemContent?> = .empty
    let context: DataController = DataController.shared
    var content: ItemContent?
    
    func load(id: ItemContent.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if content == nil {
            phase = .empty
            do {
                content = try await self.service.fetchContent(id: id, type: type)
            } catch {
                phase = .failure(error)
                content = nil
                TelemetryManager.send("ContentDetailsViewModel_load",
                                      with: ["Error":"ID=\(id)|Type=\(type.rawValue)|Error=\(error.localizedDescription)"])
            }
        }
    }
    
    func update(markAsWatched watched: Bool?, markAsFavorite favorite: Bool?) {
        if let content = content {
            if let favorite {
                HapticManager.shared.lightHaptic()
                context.updateItem(content: content, isWatched: nil, isFavorite: favorite)
            }
            else if let watched {
                HapticManager.shared.lightHaptic()
                context.updateItem(content: content, isWatched: watched, isFavorite: nil)
            }
            else {
                if context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    let item = context.getItem(id: WatchlistItem.ID(content.id))
                    if let item {
                        let identifier: String = "\(content.itemTitle)+\(content.id)"
                        if context.isNotificationScheduled(id: content.id) {
                            notification.removeNotification(identifier: identifier)
                        }
                        context.removeItem(id: item)
                    }
                } else {
                    HapticManager.shared.mediumHaptic()
                    context.saveItem(content: content, notify: content.itemCanNotify)
                    if content.itemCanNotify {
                        notification.schedule(notificationContent: content)
                    }
                }
            }
        }
    }
}
