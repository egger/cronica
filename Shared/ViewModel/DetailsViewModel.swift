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
    var content: Content? { phase.value ?? nil }
    let context: DataController = DataController.shared
    var isLoaded = false
    var isNotificationEnabled: Bool = false
   
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if phase.value == nil {
            phase = .empty
            do {
                let content = try await self.service.fetchContent(id: id, type: type)
                phase = .success(content)
                isLoaded = true
            } catch {
                phase = .failure(error)
            }

        }
//        if isLoaded != true {
//            phase = .empty
//            do {
//                let content = try await self.service.fetchContent(id: id, type: type)
//                phase = .success(content)
//                isLoaded = true
//            } catch {
//                phase = .failure(error)
//            }
//        }
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
        do {
            let item = try? context.getItem(id: WatchlistItem.ID(self.content!.id))
            if let item = item {
                if item.notify == true {
                    if let content = content {
                        self.notification.removeNotification(content: content)
                        context.updateItem(item: item, update: content, notify: false)
                        isNotificationEnabled = false
                    }
                } else {
                    if let content = content {
                        self.notification.scheduleNotification(content: content)
                        isNotificationEnabled = true
                    }
                }
            } else {
                if let content = content {
                    self.notification.scheduleNotification(content: content)
                    isNotificationEnabled = true
                }
            }
        }
    }
}
