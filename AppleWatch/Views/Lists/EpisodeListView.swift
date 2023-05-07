//
//  EpisodeListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI

struct EpisodeListView: View {
    let seasonNumber: Int
    let id: Int
    @StateObject private var viewModel = SeasonViewModel()
    @State private var isLoading = true
    @State private var episodes = [Episode]()
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                if isLoading {
                    ProgressView("Loading")
                } else {
                    List {
                        ForEach(episodes) { episode in
                            NavigationLink(value: [id:episode]) {
                                EpisodeRow(episode: episode,
                                            season: seasonNumber,
                                            show: id)
                            }
                        }
                    }
                    .onAppear {
                        guard let lastWatched = PersistenceController.shared.fetchLastWatchedEpisode(for: id) else { return }
                        withAnimation { proxy.scrollTo(lastWatched, anchor: .topLeading) }
                    }
                }
            }
            .navigationTitle("Season \(seasonNumber)")
            .task { load() }
        }
    }
    
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, season: self.seasonNumber)
            self.isLoading = false
            guard let content = viewModel.season?.episodes else { return }
            self.episodes = content
        }
    }
}
