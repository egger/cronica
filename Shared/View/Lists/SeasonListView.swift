//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

/// A View that displays a season picker, and load every episode in a given
/// season on change of the picker.
struct SeasonListView: View {
    var numberOfSeasons: [Int]?
    var tvId: Int
    var lastSelectedSeason: Int?
    @State private var selectedSeason: Int = 1
    @State private var hasFirstLoaded = false
    @StateObject private var viewModel = SeasonViewModel()
    @Binding var inWatchlist: Bool
    @Binding var seasonConfirmation: Bool
    var body: some View {
        if let numberOfSeasons {
            VStack {
                HStack {
                    Picker("Seasons", selection: $selectedSeason) {
                        ForEach(numberOfSeasons, id: \.self) { season in
                            Text("Season \(season)").tag(season)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedSeason) { season in
                        Task {
                            if Task.isCancelled { return }
                            await viewModel.load(id: self.tvId, season: season, isInWatchlist: inWatchlist)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 1)
                    .unredacted()
#if os(macOS)
                    .frame(maxWidth: 300)
#endif
                    Spacer()
#if os(macOS)
                    markSeasonAsWatched
                        .unredacted()
                        .disabled(viewModel.isLoading)
                        .padding()
#else
                    Menu {
                        markSeasonAsWatched
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                    }
                    .padding(.horizontal)
#endif
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    if viewModel.isLoading {
                        CenterHorizontalView { ProgressView() }.padding()
                    } else {
                        if let season = viewModel.season?.episodes {
                            if season.isEmpty {
                                emptySeasonView
                            } else {
                                ScrollViewReader { proxy in
                                    LazyHStack {
                                        ForEach(season) { item in
                                            EpisodeFrameView(episode: item,
                                                             season: selectedSeason,
                                                             show: tvId,
                                                             isInWatchlist: $inWatchlist)
                                            .environmentObject(viewModel)
                                            .frame(width: 160)
                                            .padding([.leading, .trailing], 4)
                                            .padding(.leading, item.id == season.first!.id ? 16 : 0)
                                            .padding(.trailing, item.id == season.last!.id ? 16 : 0)
                                        }
                                        .padding(0)
                                        .buttonStyle(.plain)
                                    }
                                    .onAppear {
                                        let lastWatchedEpisode = PersistenceController.shared.fetchLastWatchedEpisode(for: Int64(tvId))
                                        guard let lastWatchedEpisode else { return }
                                        withAnimation {
                                            proxy.scrollTo(lastWatchedEpisode, anchor: .topLeading)
                                        }
                                    }
                                    .onChange(of: selectedSeason) { _ in
                                        if !hasFirstLoaded { return }
                                        let first = season.first ?? nil
                                        guard let first else { return }
                                        withAnimation { proxy.scrollTo(first.id, anchor: .topLeading) }
                                    }
                                    .padding(0)
                                }
                            }
                        }
                    }
                }
                .padding(0)
                .task {
                    await load()
                }
                Divider().padding()
            }
            .onChange(of: viewModel.isItemInWatchlist) { value in
                if value != inWatchlist {
                    inWatchlist = value
                }
            }
            .padding(0)
            .redacted(reason: viewModel.isLoading ? .placeholder : [] )
        }
    }
    
    private var markSeasonAsWatched: some View {
        Button {
            Task {
                DispatchQueue.main.async {
                    withAnimation {
                        seasonConfirmation.toggle()
                    }
                }
                await viewModel.markSeasonAsWatched(id: tvId)
                if !inWatchlist {
                    inWatchlist = viewModel.isItemInWatchlist
                }
                HapticManager.shared.successHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        seasonConfirmation = false
                    }
                }
            }
        } label: {
            Label("Mark Season as Watched", systemImage: "checkmark.circle.fill")
        }
    }
    
    private var emptySeasonView: some View {
        CenterHorizontalView {
            VStack {
                Image(systemName: "tv.fill")
                    .font(.title)
                    .padding(.bottom, 6)
                Text("No Episode Available")
            }
            .foregroundColor(.secondary)
            .padding(.horizontal)
        }
    }
    
    private func load() async {
        if !hasFirstLoaded {
            if self.inWatchlist {
                let lastSeason = PersistenceController.shared.fetchLastSelectedSeason(for: Int64(self.tvId))
                if let lastSeason {
                    self.selectedSeason = lastSeason
                    await self.viewModel.load(id: self.tvId, season: lastSeason, isInWatchlist: inWatchlist)
                    hasFirstLoaded.toggle()
                    return
                }
            }
        }
        await self.viewModel.load(id: self.tvId, season: self.selectedSeason, isInWatchlist: inWatchlist)
    }
}

struct SeasonListView_Previews: PreviewProvider {
    @State private static var preview = false
    static var previews: some View {
        SeasonListView(numberOfSeasons: Array(1...8), tvId: 1419, inWatchlist: $preview, seasonConfirmation: $preview)
    }
}
