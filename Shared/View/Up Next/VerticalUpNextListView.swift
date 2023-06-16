//
//  VerticalUpNextListView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct VerticalUpNextListView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @State private var selectedEpisode: UpNextEpisode?
    @State private var isWatched = false
    @Binding var episodes: [UpNextEpisode]
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(episodes) { item in
                        VStack(alignment: .leading) {
                            SmallerUpNextCard(item: item)
                                .contextMenu {
                                    Button("markAsWatched") {
                                        Task { await markAsWatched(item) }
                                    }
                                    if SettingsStore.shared.markEpisodeWatchedOnTap {
                                        Button("showDetails") {
                                            selectedEpisode = item
                                        }
                                    }
    #if os(iOS) || os(macOS)
                                    Divider()
                                    if let url = URL(string: "https://www.themoviedb.org/tv/\(item.showID)/season/\(item.episode.itemSeasonNumber)/episode/\(item.episode.itemEpisodeNumber)") {
                                        ShareLink("shareEpisode", item: url)
                                    }
                                    if let url = URL(string: "https://www.themoviedb.org/tv/\(item.showID)") {
                                        ShareLink("shareShow", item: url)
                                    }
    #endif
                                }
                                .onTapGesture {
                                    if SettingsStore.shared.markEpisodeWatchedOnTap {
                                        Task { await markAsWatched(item) }
                                    } else {
                                        selectedEpisode = item
                                    }
                                }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.showTitle)
                                        .font(.callout)
                                        .lineLimit(1)
                                    Text("E\(item.episode.itemEpisodeNumber), S\(item.episode.itemSeasonNumber)")
                                        .font(.caption)
                                        .textCase(.uppercase)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .frame(width: DrawingConstants.imageWidth)
                        }
                    }
                }
                .padding()
                AttributionView()
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
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                }
#if os(macOS)
                .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
            }
            .task(id: isWatched) {
                if isWatched {
                    guard let selectedEpisode else { return }
                    await handleWatched(selectedEpisode)
                    self.selectedEpisode = nil
                }
            }
            .task {
                await checkForNewEpisodes()
            }
            .navigationTitle("upNext")
        }
    }
    
    
    func handleWatched(_ content: UpNextEpisode) async {
        let helper = EpisodeHelper()
        let nextEpisode = await helper.fetchNextEpisode(for: content.episode, show: content.showID)
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: content.showTitle,
                                            showID: content.showID,
                                            backupImage: content.backupImage,
                                            episode: nextEpisode)
                withAnimation(.easeInOut) {
                    self.episodes.insert(content, at: 0)
                }
            }
        }
        withAnimation(.easeInOut) {
            self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
        }
    }
    
    func checkForNewEpisodes() async {
        for item in items {
            let result = try? await network.fetchEpisode(tvID: item.id,
                                                         season: item.seasonNumberUpNext,
                                                         episodeNumber: item.nextEpisodeNumberUpNext)
            if let result {
                let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                           season: result.itemSeasonNumber,
                                                           episode: result.id)
                let isInEpisodeList = episodes.contains(where: { $0.episode.id == result.id })
                let isItemAlreadyLoadedInList = episodes.contains(where: { $0.showID == item.itemId })
                
                if result.isItemReleased && !isWatched && !isInEpisodeList {
                    if isItemAlreadyLoadedInList {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                self.episodes.removeAll(where: { $0.showID == item.itemId })
                            }
                        }
                    }
                    let content = UpNextEpisode(id: result.id,
                                                showTitle: item.itemTitle,
                                                showID: item.itemId,
                                                backupImage: item.image,
                                                episode: result)
                    
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            self.episodes.append(content)
                        }
                    }
                }
            }
        }
        
    }
    
    func markAsWatched(_ content: UpNextEpisode) async {
        let contentId = "\(content.showID)@\(MediaType.tvShow.toInt)"
        let item = persistence.fetch(for: contentId)
        guard let item else { return }
        persistence.updateWatchedEpisodes(for: item, with: content.episode)
        withAnimation(.easeInOut) {
            self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
        }
        HapticManager.shared.successHaptic()
        let nextEpisode = await EpisodeHelper().fetchNextEpisode(for: content.episode, show: content.showID)
        if let nextEpisode {
            if nextEpisode.isItemReleased {
                let content = UpNextEpisode(id: nextEpisode.id,
                                            showTitle: content.showTitle,
                                            showID: content.showID,
                                            backupImage: content.backupImage,
                                            episode: nextEpisode)
                persistence.updateUpNext(item, episode: nextEpisode)
                withAnimation(.easeInOut) {
                    self.episodes.insert(content, at: 0)
                }
            }
        }
    }
}

private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns = [GridItem(.adaptive(minimum: 280))]
#endif
#if os(iOS)
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
#else
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#endif
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
