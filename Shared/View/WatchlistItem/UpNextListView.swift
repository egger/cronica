//
//  UpNextListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct UpNextListView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @State private var isLoaded = false
    @State private var listItems = [UpNextEpisode]()
    @State private var selectedEpisode: Episode?
    @State private var isWatched = false
    @State private var isInWatchlist = true
    @State private var episodeShowID = [String:Int]()
    @State private var selectedEpisodeShowID: Int?
    @Binding var shouldReload: Bool
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !listItems.isEmpty {
                    NavigationLink(value: listItems) {
                        TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: true)
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(listItems) { item in
                                UpNextItem(item: item)
                                    .contextMenu {
#if os(iOS) || os(macOS)
                                        if let url = URL(string: "https://www.themoviedb.org/tv/\(item.showID)/season/\(item.episode.itemSeasonNumber)/episode/\(item.episode.itemEpisodeNumber)") {
                                            ShareLink("shareEpisode", item: url)
                                        }
                                        if let url = URL(string: "https://www.themoviedb.org/tv/\(item.showID)") {
                                            ShareLink("shareShow", item: url)
                                        }
#endif
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == self.listItems.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == self.listItems.last!.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
                                    .onTapGesture { selectedEpisode = item.episode }
                                    .accessibilityLabel("Episode \(item.episode.itemEpisodeNumber), \(item.episode.itemTitle)")
                            }
                        }
                    }
                    .redacted(reason: isLoaded ? [] : .placeholder)
                }
            }
            .navigationDestination(for: [UpNextEpisode].self) { item in
                DetailedUpNextView(list: $listItems, episodeShowID: $episodeShowID)
            }
            .task {
                print("Up Next items: \(items)")
                await load()
                
            }
            .onChange(of: shouldReload) { reload in
                if reload {
                    isLoaded = false
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            listItems.removeAll()
                        }
                    }
                    Task {
                        await load()
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                shouldReload = false
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedEpisode) { item in
#if os(iOS) || os(macOS)
                NavigationStack {
                    if let show = selectedEpisodeShowID {
                        EpisodeDetailsView(episode: item, season: item.itemSeasonNumber, show: show, isWatched: $isWatched, isUpNext: true)
                            .toolbar {
                                Button("Done") { selectedEpisode = nil }
                            }
                            .navigationDestination(for: ItemContent.self) { item in
#if os(iOS)
                                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
                            }
                    } else {
                        ProgressView()
                    }
                }
                .presentationDetents([.large])
#if os(iOS)
                .appTheme()
                .appTint()
#endif
                .task {
                    let showId = self.episodeShowID["\(item.id)"]
                    selectedEpisodeShowID = showId
                }
                .onDisappear {
                    selectedEpisode = nil
                    selectedEpisodeShowID = nil
                }
#if os(macOS)
                .frame(width: 800, height: 500)
#endif
#endif
            }
            .task(id: isWatched) {
                if isWatched {
                    guard let selectedEpisode else { return }
                    await handleWatched(selectedEpisode)
                    self.selectedEpisode = nil
                }
            }
        }
    }
    
    private func checkForNewEpisodes() {
        var loadedIDs = [Int64]()
        for item in episodeShowID {
            let value = item.value
            loadedIDs.append(Int64(value))
            if !items.contains(where: { $0.id == Int64(value) }) {
                
            }
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
    
    private func load() async {
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
                                listItems.append(content)
                                episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
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
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.listItems.insert(content, at: 0)
                        self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.listItems.removeAll(where: { $0.episode.id == episode.id })
            }
        }
    }
}

@MainActor
class UpNextViewModel: ObservableObject {
    @Published private var episodeShowID = [String:Int]()
    @Published private var isLoaded = false
    @Published private var listItems = [UpNextEpisode]()
    private let network = NetworkService.shared
    private let persistence = PersistenceController.shared
    
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
    
    private func load(_ items: [WatchlistItem]) async {
        if !isLoaded {
            for item in items {
                let result = try? await network.fetchEpisode(tvID: item.id,
                                                             season: item.seasonNumberUpNext,
                                                             episodeNumber: item.nextEpisodeNumberUpNext)
                if let result {
                    print("Episode: \(result)")
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
                                self.listItems.append(content)
                                self.episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
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
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.listItems.insert(content, at: 0)
                        self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode.id)")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.listItems.removeAll(where: { $0.episode.id == episode.id })
            }
        }
    }
}


struct UpNextEpisode: Identifiable, Hashable {
    let id: Int
    let showTitle: String
    let showID: Int
    let backupImage: URL?
    let episode: Episode
}

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


struct SmallerUpNextCard: View {
    let item: UpNextEpisode
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: item.episode.itemImageMedium ?? item.backupImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .transition(.opacity)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
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
        .frame(width: DrawingConstants.imageWidth)
        
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
    static let columns = [GridItem(.adaptive(minimum: 160))]
}
