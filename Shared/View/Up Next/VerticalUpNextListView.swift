//
//  VerticalUpNextListView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct VerticalUpNextListView: View {
    @StateObject private var settings = SettingsStore.shared
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @EnvironmentObject var viewModel: UpNextViewModel
    @State private var selectedEpisode: UpNextEpisode?
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(viewModel.episodes) { item in
                        VStack(alignment: .leading) {
                            upNextCard(item: item)
                                .contextMenu {
                                    if SettingsStore.shared.markEpisodeWatchedOnTap {
                                        Button("showDetails") {
                                            selectedEpisode = item
                                        }
                                    }
                                }
                                .onTapGesture {
                                    if SettingsStore.shared.markEpisodeWatchedOnTap {
                                        Task { await viewModel.markAsWatched(item) }
                                    } else {
                                        selectedEpisode = item
                                    }
                                }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.showTitle)
                                        .font(.caption)
                                        .lineLimit(2)
                                    Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                        .font(.caption)
                                        .textCase(.uppercase)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .frame(width: DrawingConstants.imageWidth)
                            Spacer()
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedEpisode) { item in
            NavigationStack {
                EpisodeDetailsView(episode: item.episode,
                                   season: item.episode.itemSeasonNumber,
                                   show: item.showID,
                                   showTitle: item.showTitle,
                                   isWatched: $viewModel.isWatched)
                .toolbar {
                    Button("Done") { self.selectedEpisode = nil }
                }
                .navigationDestination(for: ItemContent.self) { item in
                    ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                }
            }
#if os(macOS)
            .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
        }
        .task(id: viewModel.isWatched) {
            if viewModel.isWatched {
                await viewModel.handleWatched(selectedEpisode)
                self.selectedEpisode = nil
            }
        }
        .task {
            await viewModel.checkForNewEpisodes(items)
        }
        .navigationTitle("upNext")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    private func upNextCard(item: UpNextEpisode) -> some View {
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
            .aspectRatio(contentMode: .fill)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .transition(.opacity)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: 2)
    }
}

private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
#else
    static let columns = [GridItem(.adaptive(minimum: 280))]
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#endif
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
