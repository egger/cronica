//
//  WatchedButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct WatchedButton: View {
    let id: String
    @Binding var isWatched: Bool
    @Binding var popupConfirmationType: ActionPopupItems?
    @Binding var showConfirmationPopup: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateWatched) {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        }
    }
    
    private func updateWatched() {
        guard let item = persistence.fetch(for: id) else { return }
        persistence.updateWatched(for: item)
        withAnimation {
            isWatched.toggle()
            popupConfirmationType = isWatched ? .markedWatched : .removedWatched
            showConfirmationPopup = true
        }
        HapticManager.shared.successHaptic()
        if item.itemMedia == .tvShow { updateSeasons() }
    }
    
    private func updateSeasons() {
        Task {
            let network = NetworkService.shared
            guard let item = persistence.fetch(for: id) else { return }
            guard let content = try? await network.fetchItem(id: item.itemId, type: .tvShow) else { return }
            guard let seasons = content.itemSeasons else { return }
            var episodes = [Episode]()
            for season in seasons {
                let result = try? await network.fetchSeason(id: item.itemId, season: season)
                if let seasonEpisodes = result?.episodes {
                    for seasonEpisode in seasonEpisodes {
                        episodes.append(seasonEpisode)
                    }
                }
            }
            persistence.updateEpisodeList(to: item, show: item.itemId, episodes: episodes)
        }
    }
}

struct WatchedButton_Previews: PreviewProvider {
    static var previews: some View {
        WatchedButton(id: ItemContent.example.itemContentID,
                      isWatched: .constant(true),
                      popupConfirmationType: .constant(nil),
                      showConfirmationPopup: .constant(false))
    }
}
