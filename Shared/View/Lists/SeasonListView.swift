//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI
//#if os(iOS) || os(macOS)
///// A View that displays a season picker, and load every episode in a given
///// season on change of the picker.
//struct SeasonListView: View {
//    var numberOfSeasons: [Int]
//    var tvId: Int
//    var lastSelectedSeason: Int?
//    @State private var selectedSeason: Int = 1
//    @State private var hasFirstLoaded = false
//    @State private var previouslySelectedSeason: Int = 0
//    @StateObject private var viewModel = SeasonViewModel()
//    @Binding var inWatchlist: Bool
//    @Binding var seasonConfirmation: Bool
//    var body: some View {
//        VStack {
//            seasonHeader
//            if viewModel.isLoading {
//                CenterHorizontalView {
//                    ProgressView().padding()
//                }
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack {
//                        if let episodes = viewModel.season?.episodes {
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                ForEach(episodes) { episode in
//                                    EpisodeFrameView(episode: episode,
//                                                     season: selectedSeason,
//                                                     show: tvId)
//                                    .frame(width: 160)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            Divider().padding()
//        }
//        .onAppear { Task { await load() }}
//        .task(id: selectedSeason) {
//            await load()
//        }
//    }
//
//
//    private var seasonHeader: some View {
//        HStack {
//            Picker("Seasons", selection: $selectedSeason) {
//                ForEach(numberOfSeasons, id: \.self) { season in
//                    Text("Season \(season)").tag(season)
//                }
//            }
//            .pickerStyle(.menu)
//            .onChange(of: selectedSeason) { season in
//                Task {
//                    if Task.isCancelled { return }
//                    await viewModel.load(id: self.tvId, season: season, isInWatchlist: inWatchlist)
//                }
//            }
//            .padding(.leading)
//            .padding(.bottom, 1)
//            .unredacted()
//#if os(macOS)
//            .frame(maxWidth: 300)
//#endif
//            Spacer()
//#if os(macOS)
////            markSeasonAsWatched
////                .disabled(viewModel.isLoading)
////                .padding()
//#else
//            Menu {
//                markSeasonAsWatchedButton
//            } label: {
//                Label("More", systemImage: "ellipsis.circle")
//                    .labelStyle(.iconOnly)
//            }
//            .padding(.horizontal)
//#endif
//        }
//    }
//
//    private var markSeasonAsWatchedButton: some View {
//        Button(action: markSeasonAsWatched) {
//            Label("Mark Season as Watched", systemImage: "checkmark.circle.fill")
//        }
//        .disabled(!inWatchlist)
//    }
//
//    private func markSeasonAsWatched() {
//        viewModel.markSeasonAsWatched(id: tvId)
//        HapticManager.shared.successHaptic()
//    }
//
//    private var emptySeasonView: some View {
//        CenterHorizontalView {
//            VStack {
//                Image(systemName: "tv.fill")
//                    .font(.title)
//                    .padding(.bottom, 6)
//                Text("No Episode Available")
//            }
//            .foregroundColor(.secondary)
//            .padding(.horizontal)
//        }
//    }
//
//    private func load() async {
//        if !hasFirstLoaded && self.inWatchlist {
//            let contentId = "\(tvId)@\(MediaType.tvShow.toInt)"
//            let lastSeason = PersistenceController.shared.getLastSelectedSeason(contentId)
//            guard let lastSeason else { return }
//            self.selectedSeason = lastSeason
//            await self.viewModel.load(id: self.tvId, season: lastSeason, isInWatchlist: inWatchlist)
//            hasFirstLoaded = true
//            previouslySelectedSeason = lastSeason
//            return
//        }
//        if previouslySelectedSeason != self.selectedSeason {
//            await self.viewModel.load(id: self.tvId, season: self.selectedSeason, isInWatchlist: inWatchlist)
//            previouslySelectedSeason = self.selectedSeason
//        }
//    }
//
//}
//
//struct SeasonListView_Previews: PreviewProvider {
//    @State private static var preview = false
//    static var previews: some View {
//        SeasonListView(numberOfSeasons: Array(1...8), tvId: 1419, inWatchlist: $preview, seasonConfirmation: $preview)
//    }
//}
//#endif


//VStack {
//    seasonHeader
//    ScrollView(.horizontal, showsIndicators: false) {
//        if viewModel.isLoading {
//            CenterHorizontalView { ProgressView() }.padding()
//        } else {
//            if let season = viewModel.season?.episodes {
//                if season.isEmpty {
//                    emptySeasonView
//                } else {
//                    ScrollViewReader { proxy in
//                        LazyHStack {
//                            ForEach(season) { item in
//                                EpisodeFrameView(episode: item,
//                                                 season: selectedSeason,
//                                                 show: tvId,
//                                                 isInWatchlist: $inWatchlist)
//                                .environmentObject(viewModel)
//                                .frame(width: 160)
//                                .padding([.leading, .trailing], 4)
//                                .padding(.leading, item.id == season.first!.id ? 16 : 0)
//                                .padding(.trailing, item.id == season.last!.id ? 16 : 0)
//                            }
//                            .padding(0)
//                            .buttonStyle(.plain)
//                        }
//                        .onAppear {
//                            if hasFirstLoaded { return }
//                            let lastWatchedEpisode = PersistenceController.shared.fetchLastWatchedEpisode(for: Int64(tvId))
//                            guard let lastWatchedEpisode else { return }
//                            withAnimation {
//                                proxy.scrollTo(lastWatchedEpisode, anchor: .topLeading)
//                            }
//                        }
//                        .onChange(of: selectedSeason) { _ in
//                            if !hasFirstLoaded { return }
//                            let first = season.first ?? nil
//                            guard let first else { return }
//                            withAnimation { proxy.scrollTo(first.id, anchor: .topLeading) }
//                        }
//                        .padding(0)
//                    }
//                }
//            }
//        }
//    }
//    .padding(0)
//    .onAppear {
//        Task { await load() }
//    }
//    .task(id: selectedSeason) {
//        await load()
//    }
//    Divider().padding()
//}
//.onChange(of: viewModel.isItemInWatchlist) { value in
//    if value != inWatchlist {
//        inWatchlist = value
//    }
//}
//.padding(0)
//.redacted(reason: viewModel.isLoading ? .placeholder : [] )




struct SeasonList: View {
    let showID: Int
    let numberOfSeasons: [Int]
    @State private var lastSelectedSeason = 0
    @State private var selectedSeason = 1
    @State private var hasFirstLoaded = false
    @State private var previouslySelectedSeason = 1
    @StateObject private var viewModel = SeasonViewModel()
    private let persistence = PersistenceController.shared
    var body: some View {
        VStack {
            header
            list
            Divider().padding()
        }
        .onAppear { load() }
    }
    
    private var header: some View {
        HStack {
            Picker("Seasons", selection: $selectedSeason) {
                ForEach(numberOfSeasons, id: \.self) { season in
                    Text("Season \(season)").tag(season)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedSeason) { season in
                Task {
                    await viewModel.load(id: showID, season: season)
                }
            }
            .padding(.leading)
            .padding(.bottom, 1)
            .unredacted()
#if os(macOS)
            .frame(maxWidth: 300)
#endif
            Spacer()
        }
    }
    
    private var list: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if viewModel.isLoading {
                CenterHorizontalView { ProgressView().padding() }
            } else {
                if let season = viewModel.season?.episodes {
                    if season.isEmpty {
                        emptySeason
                    } else {
                        ScrollViewReader { proxy in
                            LazyHStack {
                                ForEach(season) { item in
                                    EpisodeFrameView(episode: item, season: selectedSeason, show: showID)
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
                                if hasFirstLoaded { return }
                                let lastWatchedEpisode = persistence.fetchLastWatchedEpisode(for: Int64(showID))
                                guard let lastWatchedEpisode else { return }
                                withAnimation {
                                    proxy.scrollTo(lastWatchedEpisode, anchor: .topLeading)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptySeason: some View {
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
    
    private func load() {
        Task {
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
                await viewModel.load(id: showID, season: lastSelectedSeason)
                hasFirstLoaded = true
                return
            }
            if previouslySelectedSeason != selectedSeason {
                await viewModel.load(id: showID, season: selectedSeason)
                previouslySelectedSeason = selectedSeason
            }
        }
    }
}
