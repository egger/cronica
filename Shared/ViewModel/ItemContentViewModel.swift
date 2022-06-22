//
//  ItemContentViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  

import Foundation
import SwiftUI

@MainActor
class ItemContentViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    let context: PersistenceController = PersistenceController.shared
    @Published var content: ItemContent?
    @Published var errorMessage: String?
    
    func load(id: ItemContent.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if content == nil {
            do {
                content = try await self.service.fetchContent(id: id, type: type)
            } catch {
                errorMessage = error.localizedDescription
                content = nil
                print(error.localizedDescription)
            }
        }
    }
    
    func update(markAsWatched watched: Bool?, markAsFavorite favorite: Bool?) {
        if let content {
            if let favorite {
                HapticManager.shared.lightHaptic()
                if !context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    context.saveItem(content: content, notify: content.itemCanNotify)
                }
                context.updateItem(content: content, isWatched: nil, isFavorite: favorite)
            }
            else if let watched {
                HapticManager.shared.lightHaptic()
                if !context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    context.saveItem(content: content, notify: content.itemCanNotify)
                }
                context.updateItem(content: content, isWatched: watched, isFavorite: nil)
            }
            else {
                if context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    HapticManager.shared.softHaptic()
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
