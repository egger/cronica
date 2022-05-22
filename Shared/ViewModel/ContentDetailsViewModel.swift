//
//  DetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import SwiftUI
import TelemetryClient

@MainActor class ContentDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let notification: NotificationManager = NotificationManager()
    @Published private(set) var phase: DataFetchPhase<Content?> = .empty
    let context: DataController = DataController.shared
    var content: Content?
    
    func load(id: Content.ID, type: MediaType) async {
        if Task.isCancelled { return }
        if content == nil {
            phase = .empty
            do {
                content = try await self.service.fetchContent(id: id, type: type)
            } catch {
                phase = .failure(error)
                content = nil
                TelemetryManager.send("ContentDetailsViewModel_load",
                                      with: ["ID-Type-Error":"ID:\(id)-Type:\(type.rawValue)-Error:\(error.localizedDescription)."])
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
