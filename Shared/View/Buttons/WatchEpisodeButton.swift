//
//  WatchEpisodeButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 15/08/22.
//

import SwiftUI

struct WatchEpisodeButton: View {
    let episode: Episode
    let season: Int
    let show: Int
    @Binding var isWatched: Bool
    @Binding var inWatchlist: Bool
    private let persistence = PersistenceController.shared
    @State private var errorMessage = false
    var body: some View {
        Button {
            update()
        } label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "rectangle.fill.badge.minus" : "rectangle.fill.badge.checkmark")
        }
    }
    
    private func update() {
        if !inWatchlist {
            Task {
                await fetch()
                handleList()
            }
        } else {
            handleList()
        }
        HapticManager.shared.successHaptic()
    }
    
    private func handleList() {
        persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
        DispatchQueue.main.async {
            withAnimation {
                isWatched.toggle()
            }
        }
    }
    
    private func fetch() async {
        let network = NetworkService.shared
        do {
            let content = try await network.fetchItem(id: show, type: .tvShow)
            persistence.save(content)
            if content.itemCanNotify && content.itemFallbackDate.isLessThanTwoMonthsAway() {
                NotificationManager.shared.schedule(content)
            }
            DispatchQueue.main.async {
                withAnimation {
                    inWatchlist = true
                }
            }
        } catch {
            if Task.isCancelled { return }
        }
    }
}
