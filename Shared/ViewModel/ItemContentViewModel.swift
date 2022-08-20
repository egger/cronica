//
//  ItemContentViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//  

import Foundation
import SwiftUI
import TelemetryClient

@MainActor
class ItemContentViewModel: ObservableObject {
    private let service = NetworkService.shared
    private let notification = NotificationManager()
    private let context = PersistenceController.shared
    private var id: ItemContent.ID
    private var type: MediaType
    @Published var content: ItemContent?
    @Published var recommendations = [ItemContent]()
    @Published var credits = [Person]()
    @Published var errorMessage: String = "Error found, try again later."
    @Published var showErrorAlert: Bool = false
    @Published var isInWatchlist = false
    @Published var isNotificationAvailable = false
    @Published var hasNotificationScheduled = false
    @Published var isWatched = false
    @Published var isFavorite = false
    @Published var isLoading = true
    @Published var showMarkAsButton = false
    
    init(id: ItemContent.ID, type: MediaType) {
        self.id = id
        self.type = type
    }
    
    func load() async {
        if Task.isCancelled { return }
        if content == nil {
            do {
                content = try await self.service.fetchContent(id: self.id, type: self.type)
                if let content {
                    isInWatchlist = context.isItemSaved(id: self.id, type: self.type)
                    withAnimation {
                        if isInWatchlist {
                            hasNotificationScheduled = isNotificationScheduled()
                            isWatched = context.isMarkedAsWatched(id: self.id)
                            isFavorite = context.isMarkedAsFavorite(id: self.id)
                        }
                        isNotificationAvailable = content.itemCanNotify
                        if content.itemStatus == .released {
                            showMarkAsButton = true
                        }
                    }
                    if recommendations.isEmpty {
                        recommendations.append(contentsOf: content.recommendations?.results.sorted { $0.itemPopularity > $1.itemPopularity } ?? [])
                    }
                    if credits.isEmpty {
                        let cast = content.credits?.cast ?? []
                        let crew = content.credits?.crew ?? []
                        let combined = cast + crew
                        credits.append(contentsOf: combined)
                    }
                    isLoading = false
                }
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                content = nil
#if targetEnvironment(simulator)
                print(error.localizedDescription)
#else
                TelemetryManager.send("fetchError", with: ["error":"\(error.localizedDescription)"])
#endif
            }
        }
    }
    
    /// Finds if a given item has notification scheduled, it's purely based on the property value when saved or updated,
    /// and might not be an actual representation if the item will notify the user.
    private func isNotificationScheduled() -> Bool {
        let item = context.fetch(for: WatchlistItem.ID(self.id))
        if let item {
            return item.notify
        }
        return false
    }
    
    func update(markAsWatched watched: Bool? = nil, markAsFavorite favorite: Bool? = nil) {
        if let content {
            if let favorite {
                HapticManager.shared.lightHaptic()
                if !context.isItemSaved(id: content.id, type: content.itemContentMedia) {
                    context.save(content)
                    withAnimation {
                        isInWatchlist.toggle()
                    }
                }
                withAnimation {
                    isFavorite.toggle()
                }
                context.update(item: content, isFavorite: favorite)
            } else if let watched {
                HapticManager.shared.lightHaptic()
                if !context.isItemSaved(id: content.id, type: content.itemContentMedia) {
                    context.save(content)
                    withAnimation {
                        isInWatchlist.toggle()
                    }
                }
                context.update(item: content, isWatched: watched)
                withAnimation {
                    isWatched.toggle()
                    hasNotificationScheduled = content.itemCanNotify
                }
            } else {
                if context.isItemSaved(id: content.id, type: content.itemContentMedia) {
                    HapticManager.shared.softHaptic()
                    let item = context.fetch(for: WatchlistItem.ID(content.id))
                    if let item {
                        let identifier: String = "\(content.itemTitle)+\(content.id)"
                        if isNotificationScheduled() {
                            notification.removeNotification(identifier: identifier)
                        }
                        context.delete(item)
                    }
                } else {
                    HapticManager.shared.mediumHaptic()
                    context.save(content)
                    if content.itemCanNotify {
                        notification.schedule(notificationContent: content)
                    }
                }
                if !isInWatchlist {
                    withAnimation {
                        hasNotificationScheduled = content.itemCanNotify
                    }
                } else {
                    withAnimation {
                        hasNotificationScheduled.toggle()
                    }
                }
            }
        }
    }
}
