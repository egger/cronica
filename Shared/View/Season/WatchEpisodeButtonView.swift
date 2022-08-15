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
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: {
            HapticManager.shared.lightHaptic()
            withAnimation {
                isWatched.toggle()
            }
            persistence.updateEpisodeList(show: show, season: season, episode: episode.id)
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
}
