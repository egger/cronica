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
    private let service = NetworkService.shared
    private let notification = NotificationManager()
    private let context = PersistenceController.shared
    private var id: ItemContent.ID
    private var type: MediaType
    @Published var content: ItemContent?
    @Published var errorMessage: String?
    @Published var isInWatchlist = false
    @Published var isNotificationAvailable = false
    @Published var hasNotificationScheduled = false
    @Published var isWatched = false
    @Published var isFavorite = false
    @Published var isLoading = true
    
    init(id: ItemContent.ID, type: MediaType) {
        self.id = id
        self.type = type
    }
    
    func load() async {
        if Task.isCancelled { return }
        if content == nil {
            do {
                content = try await self.service.fetchContent(id: self.id, type: self.type)
                if content != nil {
                    isInWatchlist = context.isItemInList(id: self.id, type: self.type)
                    if isInWatchlist {
                        withAnimation {
                            hasNotificationScheduled = isNotificationScheduled()
                            isWatched = context.isMarkedAsWatched(id: self.id)
                            isFavorite = isMarkedAsFavorite()
                        }
                    }
                    withAnimation {
                        isNotificationAvailable = content?.itemCanNotify ?? false
                    }
                    isLoading = false
                }
            } catch {
                errorMessage = error.localizedDescription
                content = nil
                print(error.localizedDescription)
            }
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    private func isNotificationScheduled() -> Bool {
        let item = context.getItem(id: WatchlistItem.ID(self.id))
        if let item {
            return item.notify
        }
        return false
    }
    
    // Returns a boolean indicating the status of 'favorite' on a given item.
    private func isMarkedAsFavorite() -> Bool {
        let item = context.getItem(id: WatchlistItem.ID(self.id))
        if let item {
            return item.favorite
        }
        return false
    }
    
    func update(markAsWatched watched: Bool? = nil, markAsFavorite favorite: Bool? = nil) {
        if let content {
            if let favorite {
                HapticManager.shared.lightHaptic()
                if !context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    context.save(item: content)
                }
                context.updateItem(content: content, isWatched: nil, isFavorite: favorite)
            }
            else if let watched {
                HapticManager.shared.lightHaptic()
                if !context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    context.save(item: content)
                }
                context.updateItem(content: content, isWatched: watched, isFavorite: nil)
            }
            else {
                if context.isItemInList(id: content.id, type: content.itemContentMedia) {
                    HapticManager.shared.softHaptic()
                    let item = context.getItem(id: WatchlistItem.ID(content.id))
                    if let item {
                        let identifier: String = "\(content.itemTitle)+\(content.id)"
                        if isNotificationScheduled() {
                            notification.removeNotification(identifier: identifier)
                        }
                        context.delete(item)
                    }
                } else {
                    HapticManager.shared.mediumHaptic()
                    context.save(item: content)
                    if content.itemCanNotify {
                        notification.schedule(notificationContent: content)
                    }
                }
            }
        }
    }
}
