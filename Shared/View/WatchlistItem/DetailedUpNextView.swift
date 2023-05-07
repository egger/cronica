//
//  DetailedUpNextView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct DetailedUpNextView: View {
    @EnvironmentObject var viewModel: UpNextViewModel
    @State private var selectedEpisode: UpNextEpisode?
    @State private var isWatched = false
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(viewModel.listItems) { item in
                        SmallerUpNextCard(item: item)
                            .onTapGesture {
                                selectedEpisode = item
                            }
                    }
                }
                .padding()
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item.episode,
                                       season: item.episode.itemSeasonNumber,
                                       show: item.showID,
                                       isWatched: $isWatched,
                                       isUpNext: true)
                    .toolbar {
                        Button("Done") { selectedEpisode = nil }
                    }
                }
#if os(macOS)
                .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
            }
            .task(id: isWatched) {
                if isWatched {
                    guard let selectedEpisode else { return }
                    await viewModel.handleWatched(selectedEpisode.episode)
                    self.selectedEpisode = nil
                }
            }
            .navigationTitle("upNext")
        }
    }
}

private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns = [GridItem(.adaptive(minimum: 280))]
#endif
}
