//
//  DetailedUpNextView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct DetailedUpNextView: View {
    @Binding var list: [UpNextEpisode]
    @Binding var episodeShowID: [String:Int]
    @State private var selectedEpisode: UpNextEpisode?
    @State private var isWatched = false
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(list) { item in
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
                    await handleWatched(selectedEpisode.episode)
                    self.selectedEpisode = nil
                }
            }
            .navigationTitle("upNext")
        }
    }
    
    private func handleWatched(_ episode: Episode) async {
        let showId = self.episodeShowID["\(episode.id)"]
        guard let showId else { return }
        let nextEpisode = await getNextEpisode(of: episode)
        let item = try? await network.fetchItem(id: showId, type: .tvShow)
        guard let item else { return }
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: item.itemTitle,
                                            showID: showId,
                                            backupImage: item.cardImageLarge,
                                            episode: nextEpisode)
                withAnimation(.easeInOut) {
                    self.list.insert(content, at: 0)
                    self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                }
            }
        }
        withAnimation(.easeInOut) {
            self.list.removeAll(where: { $0.episode.id == episode.id })
        }
    }
    
    private func getNextEpisode(of actual: Episode) async -> Episode? {
        guard let showID = self.episodeShowID["\(actual.id)"] else { return nil }
        let season = try? await network.fetchSeason(id: showID, season: actual.itemSeasonNumber)
        guard let episodes = season?.episodes else { return nil }
        let episodeCount = actual.itemEpisodeNumber + 1
        if episodes.count < episodeCount {
            let nextSeasonNumber = actual.itemSeasonNumber + 1
            let nextSeason = try? await network.fetchSeason(id: showID, season: nextSeasonNumber)
            guard let nextSeasonEpisodes = nextSeason?.episodes else { return nil }
            let nextEpisode = nextSeasonEpisodes[0]
            if nextEpisode.isItemReleased {
                if persistence.isEpisodeSaved(show: showID, season: nextSeasonNumber, episode: nextEpisode.id) { return nil }
                return nextEpisode
            }
        } else {
            let nextEpisode = episodes.filter { $0.itemEpisodeNumber == episodeCount }
            if nextEpisode.isEmpty { return nil }
            let episode = nextEpisode[0]
            if persistence.isEpisodeSaved(show: showID, season: episode.itemSeasonNumber, episode: episode.id) { return nil }
            return episode
        }
        return nil
    }
}


private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns = [GridItem(.adaptive(minimum: 280))]
#endif
}
