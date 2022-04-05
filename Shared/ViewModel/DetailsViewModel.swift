//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import UserNotifications
import SwiftUI

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
            }
        }
    }
    
    func update() {
        if let content = content {
            if context.isItemInList(id: content.id) {
                let item = try? context.getItem(id: WatchlistItem.ID(content.id))
                if let item = item {
                    if context.isNotificationScheduled(id: content.id) {
                        notification.removeNotification(content: content)
                    }
                    try? context.removeItem(id: item)
                }
            } else {
                context.saveItem(content: content)
                if content.itemCanNotify { notificationManager() }
            }
        }
    }
    
    private func notificationManager() {
        if let content = content {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    try? self.notification.scheduleNotification(content: content)
                } else if settings.authorizationStatus == .notDetermined {
                    self.notification.requestAuthorization { granted in
                        if granted == true {
                           try? self.notification.scheduleNotification(content: content)
                        }
                    }
                }
            }
        }
    }
}
