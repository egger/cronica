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
        Button(action: {
            update()
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "rectangle.fill.badge.minus" : "rectangle.fill.badge.checkmark")
        })
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
    }
    
    private func handleList() {
        DispatchQueue.main.async {
            withAnimation {
                isWatched.toggle()
            }
        }
        persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
    }
    
    private func fetch() async {
        let network = NetworkService.shared
        let content = try? await network.fetchItem(id: show, type: .tvShow)
        if let content {
            persistence.save(content)
            DispatchQueue.main.async {
                withAnimation {
                    inWatchlist = true
                }
            }
        }
    }
}
