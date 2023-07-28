//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

struct SeasonList: View {
    let showID: Int
    let showTitle: String
    let numberOfSeasons: [Int]
    @State private var lastSelectedSeason = 0
    @State private var selectedSeason = 1
    @State private var hasFirstLoaded = false
    @State private var isLoading = true
    @State private var previouslySelectedSeason = 1
    @State private var season: Season?
    @State private var checkIfWatched = false
    private let persistence = PersistenceController.shared
    private let network = NetworkService.shared
    var body: some View {
        VStack {
            header
            list
        }
        .task {
            if !hasFirstLoaded {
                await load()
            }
        }
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }
    
    private var header: some View {
        HStack {
            Picker(selection: $selectedSeason) {
                ForEach(numberOfSeasons, id: \.self) { season in
#if os(tvOS)
                    Text("\(season)").tag(season)
#else
                    Text("Season \(season)").tag(season)
#endif
                }
            } label: {
#if os(iOS) || os(tvOS)
                Text("Season")
                    .lineLimit(1)
#endif
            }
#if os(tvOS)
            .pickerStyle(.navigationLink)
#elseif os(macOS)
            .pickerStyle(.automatic)
#else
            .pickerStyle(.menu)
#endif
            .onChange(of: selectedSeason) { _ in
                Task { await load() }
            }
            .padding(.leading)
            .padding(.bottom, 1)
            .unredacted()
#if os(macOS)
            .frame(maxWidth: 200)
#elseif os(tvOS)
            .frame(maxWidth: 460)
            .padding(.leading, 64)
#endif
            Spacer()
#if os(iOS) 
            Menu {
                Button("markThisSeasonAsWatched", action: markSeasonAsWatched)
                if let url = URL(string: "https://www.themoviedb.org/tv/\(showID)/season/\(selectedSeason)") {
                    ShareLink(item: url)
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
            }
            .padding(.horizontal)
#endif
        }
    }
    
    private var list: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if isLoading {
                CenterHorizontalView { ProgressView().padding() }
            } else {
                if let season = season?.episodes {
                    if season.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "tv.fill")
                                    .font(.title)
                                    .padding(.bottom, 6)
                                Text("No Episode Available")
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        ScrollViewReader { proxy in
                            VStack {
                                LazyHStack {
                                    ForEach(season) { item in
                                        EpisodeFrameView(episode: item,
                                                         season: selectedSeason,
                                                         show: showID,
                                                         showTitle: showTitle,
                                                         checkedIfWatched: $checkIfWatched)
#if os(tvOS)
                                        .frame(width: 360)
                                        .padding([.leading, .trailing], 2)
                                        .padding(.leading, item.id == season.first!.id ? 64 : 0)
                                        .padding(.trailing, item.id == season.last!.id ? 64 : 0)
#else
                                        .frame(width: 200)
                                        .padding([.leading, .trailing], 4)
                                        .padding(.leading, item.id == season.first!.id ? 16 : 0)
                                        .padding(.trailing, item.id == season.last!.id ? 16 : 0)
#endif
                                        
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .onAppear {
                                if !hasFirstLoaded { return }
                                let lastWatchedEpisode = persistence.fetchLastWatchedEpisode(for: showID)
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
                        }
                    }
                }
            }
        }
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }
    
    private func load() async {
        let contentId = "\(showID)@\(MediaType.tvShow.toInt)"
        let isShowSaved = persistence.isItemSaved(id: contentId)
        if !hasFirstLoaded && isShowSaved {
            let lastPickedSeason = persistence.getLastSelectedSeason(contentId)
            guard let lastPickedSeason else {
                self.lastSelectedSeason = 1
                return
            }
            self.previouslySelectedSeason = lastPickedSeason
            self.selectedSeason = lastPickedSeason
            self.lastSelectedSeason = lastPickedSeason
            await fetch(season: lastSelectedSeason)
        } else if previouslySelectedSeason != selectedSeason {
            await fetch(season: selectedSeason)
            previouslySelectedSeason = selectedSeason
        } else {
            if hasFirstLoaded && lastSelectedSeason == selectedSeason { return }
            await fetch(season: selectedSeason)
            previouslySelectedSeason = selectedSeason
        }
        self.hasFirstLoaded = true
    }
    
    private func fetch(season: Int) async {
        do {
            if Task.isCancelled { return }
            withAnimation { isLoading = true }
            self.season = try await network.fetchSeason(id: showID, season: season)
            withAnimation { isLoading = false }
        } catch {
            if Task.isCancelled { return }
            let message = "Season \(season), id: \(showID), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "SeasonViewModel.load.failed")
            withAnimation { isLoading = false }
        }
    }
    
    private func markSeasonAsWatched() {
        guard let episodes = season?.episodes else { return }
        for episode in episodes {
            if !persistence.isEpisodeSaved(show: showID, season: episode.itemSeasonNumber, episode: episode.id) {
                persistence.updateEpisodeList(show: showID, season: episode.itemSeasonNumber, episode: episode.id)
            }
        }
        checkIfWatched = true
    }
}
