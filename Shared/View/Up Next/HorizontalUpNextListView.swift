//
//  HorizontalUpNextListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI

struct HorizontalUpNextListView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @State private var isWatched = false
    @Binding var shouldReload: Bool
    @State private var selectedEpisode: UpNextEpisode?
    @State var isLoaded = false
    @State var episodes = [UpNextEpisode]()
    @State private var scrollToInitial = false
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !episodes.isEmpty {
#if !os(tvOS)
                    NavigationLink(value: episodes) {
                        TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: true)
                    }
                    .buttonStyle(.plain)
#else
                    TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: false)
                        .padding(.leading, 32)
#endif
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(episodes) { item in
#if os(tvOS)
                                    Button {
                                        selectedEpisode = item
                                    } label: {
                                        UpNextItem(item: item)
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == episodes.first!.id ? 32 : 0)
                                    .padding(.trailing, item.id == episodes.last!.id ? 32 : 0)
                                    .padding(.top, 8)
                                    .padding(.vertical)
                                    .buttonStyle(.card)
#else
                                    UpNextItem(item: item)
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
                                            Divider()
                                            Button("hideFromUpNext") {
                                                
                                            }.hidden()
#endif
                                        }
                                        .padding([.leading, .trailing], 4)
                                        .padding(.leading, item.id == episodes.first!.id ? 16 : 0)
                                        .padding(.trailing, item.id == episodes.last!.id ? 16 : 0)
                                        .padding(.top, 8)
                                        .padding(.bottom)
                                        .onTapGesture {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Task { await markAsWatched(item) }
                                            } else {
                                                selectedEpisode = item
                                            }
                                        }
#endif
                                }
                            }
                            .onChange(of: isWatched) { _ in
                                guard let first = episodes.first else { return }
                                if isWatched {
                                    withAnimation {
                                        proxy.scrollTo(first.id, anchor: .topLeading)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .redacted(reason: isLoaded ? [] : .placeholder)
            .navigationDestination(for: [UpNextEpisode].self) { _ in
                VerticalUpNextListView(episodes: $episodes)
            }
            .task(id: isWatched) {
                if isWatched {
                    guard let selectedEpisode else { return }
                    await handleWatched(selectedEpisode)
                    self.selectedEpisode = nil
                }
            }
            .task {
                await load()
                await checkForNewEpisodes()
            }
            .onChange(of: shouldReload) { reload in
                if reload {
                    Task {
                        await self.reload()
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                self.shouldReload = false
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item.episode,
                                       season: item.episode.itemSeasonNumber,
                                       show: item.showID,
                                       isWatched: $isWatched,
                                       isUpNext: true)
#if os(macOS) || os(iOS)
                    .toolbar { Button("Done") { selectedEpisode = nil } }
#endif
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                }
#if os(macOS)
                .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
            }
        }
    }
    
    
    func load() async {
        if !isLoaded {
            for item in items {
                let result = try? await network.fetchEpisode(tvID: item.id,
                                                             season: item.seasonNumberUpNext,
                                                             episodeNumber: item.nextEpisodeNumberUpNext)
                if let result {
                    let isWatched = persistence.isEpisodeSaved(show: item.itemId,
                                                               season: result.itemSeasonNumber,
                                                               episode: result.id)
                    
                    if result.isItemReleased && !isWatched {
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
            DispatchQueue.main.async {
                withAnimation { self.isLoaded = true }
            }
        }
    }
    
    func reload() async {
        withAnimation { self.isLoaded = false }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.episodes.removeAll()
            }
        }
        Task { await load() }
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
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.episodes.insert(content, at: 0)
                        self.scrollToInitial = true
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
            }
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
                            self.episodes.insert(content, at: 0)
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
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.episodes.removeAll(where: { $0.episode.id == content.episode.id })
            }
        }
        HapticManager.shared.successHaptic()
        let nextEpisode = await EpisodeHelper().fetchNextEpisode(for: content.episode, show: content.showID)
        guard let nextEpisode else { return }
        persistence.updateUpNext(item, episode: nextEpisode)
        if nextEpisode.isItemReleased {
            let content = UpNextEpisode(id: nextEpisode.id,
                                        showTitle: content.showTitle,
                                        showID: content.showID,
                                        backupImage: content.backupImage,
                                        episode: nextEpisode)
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.episodes.insert(content, at: 0)
                }
            }
        }
    }
}
