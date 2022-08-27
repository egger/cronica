//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

/// A View that displays a season picker, and load every episode in a given
/// season on change of the picker.
struct SeasonsView: View {
    var numberOfSeasons: [Int]?
    var tvId: Int
    @State private var selectedSeason: Int = 1
    @State private var selectedEpisode: Episode? = nil
    @StateObject private var viewModel: SeasonViewModel
    @Binding var inWatchlist: Bool
    @Binding var seasonConfirmation: Bool
    init(numberOfSeasons: [Int]?, tvId: Int, inWatchlist: Binding<Bool>, seasonConfirmation: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.numberOfSeasons = numberOfSeasons
        self.tvId = tvId
        self._inWatchlist = inWatchlist
        self._seasonConfirmation = seasonConfirmation
    }
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
                    .onChange(of: selectedSeason) { _ in
                        load()
                    }
                    .padding(.leading)
                    .padding(.bottom, 1)
                    .unredacted()
                    Spacer()
                    Menu {
                        Button(action: {
                            Task {
                                withAnimation {
                                    seasonConfirmation.toggle()
                                }
                                await viewModel.markSeasonAsWatched(id: tvId)
                                if !inWatchlist {
                                    inWatchlist = viewModel.isItemInWatchlist
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation {
                                        seasonConfirmation = false
                                    }
                                }
                                
                            }
                        }, label: {
                            Label("Mark Season as Watched", systemImage: "checkmark.circle.fill")
                        })
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                    }
                    .padding(.horizontal)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    if let season = viewModel.season?.episodes {
                        if season.isEmpty {
                            emptySeasonView
                        } else {
                            LazyHStack {
                                ForEach(season) { item in
                                    EpisodeFrameView(episode: item,
                                                     season: selectedSeason,
                                                     show: tvId,
                                                     isInWatchlist: $inWatchlist)
                                    .environmentObject(viewModel)
                                    .frame(width: 160, height: 200)
                                    .onTapGesture {
                                        selectedEpisode = item
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == season.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == season.last!.id ? 16 : 0)
                                }
                                .padding(0)
                                .buttonStyle(.plain)
                            }
                            .padding(0)
                        }
                    }
                }
                .padding(0)
                .task {
                    load()
                }
            }
            .onChange(of: viewModel.isItemInWatchlist) { value in
                if value != inWatchlist {
                    inWatchlist = value
                }
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item, season: selectedSeason, show: tvId, isInWatchlist: $inWatchlist)
                        .environmentObject(viewModel)
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    selectedEpisode = nil
                                }
                            }
                        }
                }
            }
            .padding(0)
            .redacted(reason: viewModel.isLoading ? .placeholder : [] )
        }
    }
    
    private var emptySeasonView: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "tv.fill")
                    .padding(.bottom, 6)
                Text("No Episode Available")
            }
            .foregroundColor(.secondary)
            .padding(.horizontal)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func load() {
        Task {
            await self.viewModel.load(id: self.tvId, season: self.selectedSeason, isInWatchlist: inWatchlist)
        }
    }
}

struct HorizontalSeasonView_Previews: PreviewProvider {
    @State private static var preview = false
    static var previews: some View {
        SeasonsView(numberOfSeasons: Array(1...8), tvId: 1419, inWatchlist: $preview, seasonConfirmation: $preview)
    }
}
