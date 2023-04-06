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
    @Binding var inWatchlist: Bool
    @StateObject private var viewModel: SeasonViewModel
    @State private var isLoading = true
    init(seasonNumber: Int, id: Int, inWatchlist: Binding<Bool>) {
        self.seasonNumber = seasonNumber
        self.id = id
        self._inWatchlist = inWatchlist
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
    }
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                if isLoading {
                    ProgressView("Loading")
                } else {
                    if let episodes = viewModel.season?.episodes {
                        List {
                            ForEach(episodes) { episode in
                                NavigationLink(destination: EpisodeDetailsView(episode: episode,
                                                                               season: seasonNumber,
                                                                               show: id)) {
                                    EpisodeView(episode: episode,
                                                season: seasonNumber,
                                                show: id,
                                                isInWatchlist: $inWatchlist)
                                }
                            }
                        }
                        .onAppear {
                            let lastWatchedEpisode = PersistenceController.shared.fetchLastWatchedEpisode(for: Int64(id))
                            guard let lastWatchedEpisode else { return }
                            withAnimation {
                                proxy.scrollTo(lastWatchedEpisode, anchor: .topLeading)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Season \(seasonNumber)")
            .task { load() }
        }
    }
    
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, season: self.seasonNumber, isInWatchlist: inWatchlist)
            self.isLoading = false
        }
    }
}
