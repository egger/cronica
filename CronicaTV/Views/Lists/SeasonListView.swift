//
//  SeasonListView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct SeasonListView: View {
    var numberOfSeasons: [Int]?
    let id: Int
    @Binding var inWatchlist: Bool
    var lastSelectedSeason: Int?
    @State private var selectedSeason: Int = 1
    @State private var selectedEpisode: Episode? = nil
    @State private var hasFirstLoaded = false
    @StateObject private var viewModel = SeasonViewModel()
    var body: some View {
        if let numberOfSeasons {
            VStack {
                HStack(alignment: .center) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            Picker("Seasons", selection: $selectedSeason) {
                                ForEach(numberOfSeasons, id: \.self) { season in
                                    Text("Season \(season)").tag(season)
                                }
                            }
                            .padding([.trailing, .leading], 16)
                            .padding([.top, .bottom])
                        }
                        .onChange(of: selectedSeason) { season in
                            proxy.scrollTo(season, anchor: .topLeading)
                            Task {
                                await viewModel.load(id: self.id, season: season, isInWatchlist: inWatchlist)
                            }
                        }
                    }
                    
                }
                ScrollView(.horizontal) {
                    if let season = viewModel.season?.episodes {
                        if season.isEmpty {
                            CenterHorizontalView {
                                Text("No Episodes Available")
                            }
                        } else {
                            ScrollViewReader { proxy in
                                LazyHStack {
                                    ForEach(season) { item in
                                        VStack {
                                            Button {
                                                selectedEpisode = item
                                            } label: {
                                                EpisodeItemFrame(episode: item, show: id)
                                            }
                                            .buttonStyle(.card)
                                            VStack(alignment: .leading) {
                                                Text(item.itemTitle)
                                                    .lineLimit(1)
                                                    .font(.caption)
                                                Text(item.itemOverview)
                                                    .lineLimit(2)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.trailing)
                                            .frame(maxWidth: 360)
                                        }
                                        .padding([.leading, .trailing], 4)
                                        .buttonStyle(.plain)
                                        .padding(.leading, item.id == season.first!.id ? 16 : 0)
                                        .padding(.trailing, item.id == season.last!.id ? 16 : 0)
                                        .padding([.top, .bottom])
                                    }
                                }
                                .onAppear {
                                    let lastWatchedEpisode = PersistenceController.shared.fetchLastWatchedEpisode(for: Int64(id))
                                    guard let lastWatchedEpisode else { return }
                                    withAnimation {
                                        proxy.scrollTo(lastWatchedEpisode, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item, id: id, season: selectedSeason, inWatchlist: $inWatchlist)
                }
            }
            .task {
                load()
            }
        }
    }
    
    private func load() {
        Task {
            if !hasFirstLoaded {
                if self.inWatchlist {
                    let lastSeason = PersistenceController.shared.fetchLastSelectedSeason(for: Int64(self.id))
                    if let lastSeason {
                        self.selectedSeason = lastSeason
                        await self.viewModel.load(id: self.id, season: lastSeason, isInWatchlist: inWatchlist)
                        hasFirstLoaded.toggle()
                        return
                    }
                }
            }
            await self.viewModel.load(id: self.id, season: self.selectedSeason, isInWatchlist: inWatchlist)
        }
    }
}
