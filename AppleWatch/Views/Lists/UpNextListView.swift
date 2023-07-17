//
//  UpNextListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 17/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpNextListView: View {
    @StateObject private var viewModel = UpNextViewModel()
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @State private var selectedEpisode: UpNextEpisode?
    var body: some View {
        NavigationStack {
            if items.isEmpty {
                Text("Mark some episodes as watched to use Up Next.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(viewModel.episodes) { episode in
                        upNextRowItem(episode)
                            .onTapGesture {
                                selectedEpisode = episode
                            }
                    }
                }
                .overlay { if !viewModel.isLoaded { ProgressView() } }
                .task(id: viewModel.isWatched) {
                    if viewModel.isWatched {
                        await viewModel.handleWatched(selectedEpisode)
                        self.selectedEpisode = nil
                    }
                }
                .task {
                    await viewModel.load(items)
                    await viewModel.checkForNewEpisodes(items)
                }
                .sheet(item: $selectedEpisode) { item in
                    NavigationStack {
                        EpisodeDetailsView(episode: item.episode,
                                           season: item.episode.itemSeasonNumber,
                                           show: item.showID,
                                           showTitle: item.showTitle,
                                           isWatched: $viewModel.isWatched)
                        .onDisappear {
                            self.selectedEpisode = nil
                        }
                    }
                }
                .navigationTitle("upNext")
            }
        }
    }
    
    private func upNextRowItem(_ item: UpNextEpisode) -> some View {
        HStack {
            WebImage(url: item.episode.itemImageMedium ?? item.backupImage)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "tv")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
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
            .padding(.leading, 2)
            Spacer()
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
    static let textLimit: Int = 1
}

struct UpNextListView_Previews: PreviewProvider {
    static var previews: some View {
        UpNextListView()
    }
}
