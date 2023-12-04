//
//  UpNextMenuBar.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/11/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpNextMenuBar: View {
    @StateObject private var viewModel: UpNextViewModel = .shared
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    var body: some View {
        Form {
            Section {
                List {
                    ForEach(viewModel.episodes) { item in
                        upNextRowItem(item)
                            .onTapGesture {
                                Task { await viewModel.markAsWatched(item) }
                            }
                            .padding(.top, item == viewModel.episodes.first ? 8 : 0)
                            .padding(.top, item == viewModel.episodes.last ? 8 : 0)
                    }
                }
                .overlay {
                    if !viewModel.isLoaded {
                        ProgressView("Loading")
                    }
                }
                .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            } header: {
                HStack {
                    Text("Up Next")
                        .font(.callout)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await viewModel.reload(items) }
                    }
                    .labelStyle(.iconOnly)
                }
                
            }
        }
        .task {
            await viewModel.load(items)
            await viewModel.checkForNewEpisodes(items)
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func upNextRowItem(_ item: UpNextEpisode) -> some View {
        HStack {
            WebImage(url: item.episode.itemImageSmall ?? item.backupImage)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 95, height: 50)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: 95, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading) {
                Text(item.showTitle)
                    .font(.callout)
                    .lineLimit(1)
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
