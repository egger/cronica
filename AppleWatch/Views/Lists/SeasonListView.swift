//
//  SeasonListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct SeasonListView: View {
    var numberOfSeasons: [Int]
    var id: Int
    @Binding var isInWatchlist: Bool
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                List {
                    ForEach(numberOfSeasons, id: \.self) { season in
                        NavigationLink(
                            destination: EpisodeListView(seasonNumber: season, id: id, inWatchlist: $isInWatchlist),
                            label: {
                                Text("Season \(season)")
                            })
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                markSeasonAsWatched(season: season)
                            } label: {
                                Label("Mark season as watched", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                    }
                }
                .onAppear {
                    let lastSeason = PersistenceController.shared.fetchLastSelectedSeason(for: Int64(id))
                    guard let lastSeason else { return }
                    withAnimation {
                        proxy.scrollTo(lastSeason, anchor: .topLeading)
                    }
                }
            }
            .navigationTitle("Seasons")
        }
    }
    
    private func markSeasonAsWatched(season: Int) {
        Task {
            do {
                let result = try await NetworkService.shared.fetchSeason(id: id, season: season)
                guard let episodes = result.episodes else { return }
                for episode in episodes {
                    PersistenceController.shared.updateEpisodeList(show: id,
                                                                   season: season,
                                                                   episode: episode.id)
                }
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                                for: "markSeasonAsWatched() watchOS")
            }
        }
    }
}
