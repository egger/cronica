//
//  UpNextView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct UpNextView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSPredicate(format: "displayOnUpNext == %d", true)
    ) var items: FetchedResults<WatchlistItem>
    @State private var isLoaded = false
    @State private var episodes = [Episode]()
    @State private var selectedEpisode: Episode?
    @State private var nextEpisode: Episode?
    @State private var isWatched = false
    @State private var isInWatchlist = true
    @State private var episodeShowID = [String:Int]()
    @State private var selectedEpisodeShowID: Int?
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                NavigationLink(value: episodes) {
                    TitleView(title: "upNext", showChevron: false)
                }
                .buttonStyle(.plain)
                if !isLoaded {
                    CenterHorizontalView { ProgressView() }
                        .frame(height: 80)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(episodes) { episode in
                                UpNextEpisodeCardPrototype(episode: episode)
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, episode.id == self.episodes.first!.id ? 16 : 0)
                                    .padding(.trailing, episode.id == self.episodes.last!.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
                                    .onTapGesture {
                                        if SettingsStore.shared.markEpisodeWatchedOnTap {
                                            Task { await markAsWatched(for: episode) }
                                        } else {
                                            selectedEpisode = episode
                                        }
                                        
                                    }
                                    .contextMenu {
                                        Button {
                                            Task { await markAsWatched(for: episode) }
                                        } label: {
                                            Label("markAsWatched", systemImage: "rectangle.badge.checkmark.fill")
                                        }
                                    } preview: {
                                        ZStack {
                                            WebImage(url: episode.itemImageLarge)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .overlay {
                                                    VStack {
                                                        Spacer()
                                                        ZStack(alignment: .bottom) {
                                                            Color.black.opacity(0.4)
                                                                .frame(height: 70)
                                                                .mask {
                                                                    LinearGradient(colors: [Color.black,
                                                                                            Color.black.opacity(0.924),
                                                                                            Color.black.opacity(0.707),
                                                                                            Color.black.opacity(0.383),
                                                                                            Color.black.opacity(0)],
                                                                                   startPoint: .bottom,
                                                                                   endPoint: .top)
                                                                }
                                                            Rectangle()
                                                                .fill(.ultraThinMaterial)
                                                                .frame(height: 70)
                                                                .mask {
                                                                    VStack(spacing: 0) {
                                                                        LinearGradient(colors: [Color.black.opacity(0),
                                                                                                Color.black.opacity(0.383),
                                                                                                Color.black.opacity(0.707),
                                                                                                Color.black.opacity(0.924),
                                                                                                Color.black],
                                                                                       startPoint: .top,
                                                                                       endPoint: .bottom)
                                                                        .frame(height: 70)
                                                                        Rectangle()
                                                                    }
                                                                }
                                                            HStack {
                                                                Text(episode.itemTitle)
                                                                    .font(.title3)
                                                                    .foregroundColor(.white)
                                                                    .fontWeight(.semibold)
                                                                    .lineLimit(1)
                                                                    .padding()
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                            
                                        }
                                        .frame(width: 320, height: 180)
                                    }
                            }
                        }
                    }
                }
            }
            .task {
                await load()
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    if let show = selectedEpisodeShowID {
                        EpisodeDetailsView(episode: item, nextEpisode: $nextEpisode, season: item.itemSeasonNumber, show: show, isWatched: $isWatched, isInWatchlist: $isInWatchlist)
                            .toolbar {
                                Button("Done") { selectedEpisode = nil }
                            }
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
#endif
                    } else {
                        ProgressView()
                    }
                }
                .presentationDetents([.medium, .large])
                .appTheme()
                .appTint()
                .task {
                    let showId = self.episodeShowID["\(item.id)"]
                    selectedEpisodeShowID = showId
                    if nextEpisode == nil {
                        nextEpisode = await fetchNextEpisode(for: item)
                    }
                    print(showId as Any)
                }
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
    
    private func load() async {
        if !isLoaded {
            for item in items {
                do {
                    let result = try await NetworkService.shared.fetchEpisode(tvID: item.id,
                                                                              season: item.seasonNumberUpNext,
                                                                              episodeNumber: item.nextEpisodeNumberUpNext)
                    episodes.append(result)
                    episodeShowID.updateValue(item.itemId, forKey: "\(result.id)")
                } catch {
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
                }
            }
            DispatchQueue.main.async {
                self.isLoaded = true
            }
        }
    }
    
    private func markAsWatched(for episode: Episode) async {
        do {
            let showId = self.episodeShowID["\(episode.id)"]
            guard let showId else { return }
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: showId, season: episode.itemSeasonNumber)
            guard let episodes = season.episodes else { return }
            let nextEpisodeCount = episode.itemEpisodeNumber+1
            if episodes.count < nextEpisodeCount { return }
            else {
                let nextEpisode = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                let persistence = PersistenceController.shared
                persistence.updateEpisodeList(show: showId,
                                              season: episode.itemSeasonNumber,
                                              episode: episode.id,
                                              nextEpisode: nextEpisode[0])
                HapticManager.shared.successHaptic()
                self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode[0].id)")
                DispatchQueue.main.async {
                    withAnimation {
                        self.episodes.removeAll(where: { $0.id == episode.id })
                        self.episodes.insert(nextEpisode[0], at: 0)
                    }
                }
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
        }
    }
    
    private func handleWatched(_ episode: Episode) async {
        do {
            let showId = self.episodeShowID["\(episode.id)"]
            guard let showId else { return }
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: showId, season: episode.itemSeasonNumber)
            guard let episodes = season.episodes else { return }
            let nextEpisodeCount = episode.itemEpisodeNumber+1
            if episodes.count < nextEpisodeCount { return }
            else {
                let nextEpisode = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                withAnimation {
                    self.episodes.insert(nextEpisode[0], at: 0)
                    self.episodeShowID.updateValue(showId, forKey: "\(nextEpisode[0].id)")
                    self.episodes.removeAll(where: { $0.id == episode.id })
                }
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
        }
    }
    
    private func fetchNextEpisode(for actual: Episode) async -> Episode? {
        do {
            let showId = self.episodeShowID["\(actual.id)"]
            guard let showId else { return nil }
            let network = NetworkService.shared
            let season = try await network.fetchSeason(id: showId, season: actual.itemSeasonNumber)
            guard let episodes = season.episodes else { return nil }
            let nextEpisodeCount = actual.itemEpisodeNumber+1
            if episodes.count < nextEpisodeCount { return nil }
            else {
                let nextEpisode = episodes.filter { $0.itemEpisodeNumber == nextEpisodeCount }
                return nextEpisode[0]
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "")
            return nil
        }
    }
}


struct UpNextView_Previews: PreviewProvider {
    static var previews: some View {
        UpNextView()
    }
}

private struct UpNextEpisodeCardPrototype: View {
    let episode: Episode
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: episode.itemImageLarge)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv.fill")
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 240, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 2.5)
                .transition(.opacity)
            Text("Episode \(episode.itemEpisodeNumber), Season \(episode.itemSeasonNumber)")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .lineLimit(1)
            Text(episode.itemTitle)
                .font(.callout)
                .lineLimit(1)
        }
        .frame(width: 240, height: 170)
    }
}
