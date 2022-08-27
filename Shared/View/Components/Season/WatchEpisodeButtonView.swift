//
//  WatchEpisodeButtonView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 15/08/22.
//

import SwiftUI

struct WatchEpisodeButtonView: View {
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
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private func update() {
        HapticManager.shared.lightHaptic()
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
        withAnimation {
            isWatched.toggle()
        }
        persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
    }
    
    private func fetch() async {
        let network = NetworkService.shared
        let content = try? await network.fetchContent(id: show, type: .tvShow)
        if let content {
            persistence.save(content)
            withAnimation {
                inWatchlist = true
            }
        }
    }
}
