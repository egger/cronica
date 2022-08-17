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
    init(numberOfSeasons: [Int]?, tvId: Int) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.numberOfSeasons = numberOfSeasons
        self.tvId = tvId
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
                                await viewModel.markSeasonAsWatched(id: tvId)
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
                    LazyHStack {
                        if let season = viewModel.season?.episodes {
                            if !season.isEmpty {
                                ForEach(season) { item in
                                    EpisodeFrameView(episode: item, season: selectedSeason, show: tvId)
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
                            } else {
                                emptySeasonView
                            }
                        } else {
                            emptySeasonView
                        }
                    }
                    .padding(0)
                }
                .padding(0)
                .task {
                    load()
                }
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item, season: selectedSeason, show: tvId)
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
                Text("No Episode Available")
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func load() {
        Task {
            await self.viewModel.load(id: self.tvId, season: self.selectedSeason)
        }
    }
}

struct HorizontalSeasonView_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsView(numberOfSeasons: Array(1...8), tvId: 1419)
    }
}
