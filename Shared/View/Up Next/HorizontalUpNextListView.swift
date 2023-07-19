//
//  HorizontalUpNextListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct HorizontalUpNextListView: View {
    @Binding var shouldReload: Bool
    @State private var selectedEpisode: UpNextEpisode?
    @StateObject private var settings = SettingsStore.shared
    @StateObject private var viewModel = UpNextViewModel()
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !viewModel.episodes.isEmpty {
#if !os(tvOS)
                    NavigationLink(value: viewModel.episodes) {
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
                                ForEach(viewModel.episodes) { item in
#if os(tvOS)
                                    Button {
                                        selectedEpisode = item
                                    } label: {
                                        upNextCard(item)
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == viewModel.episodes.first!.id ? 32 : 0)
                                    .padding(.trailing, item.id == viewModel.episodes.last!.id ? 32 : 0)
                                    .padding(.top, 8)
                                    .padding(.vertical)
                                    .buttonStyle(.card)
#else
                                    upNextCard(item)
                                        .contextMenu {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Button("showDetails") {
                                                    selectedEpisode = item
                                                }
                                            }
                                        }
                                        .padding([.leading, .trailing], 4)
                                        .padding(.leading, item.id == viewModel.episodes.first!.id ? 16 : 0)
                                        .padding(.trailing, item.id == viewModel.episodes.last!.id ? 16 : 0)
                                        .padding(.top, 8)
                                        .padding(.bottom)
                                        .onTapGesture {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Task { await viewModel.markAsWatched(item) }
                                            } else {
                                                selectedEpisode = item
                                            }
                                        }
#endif
                                }
                            }
                            .onChange(of: viewModel.isWatched) { _ in
                                guard let first = viewModel.episodes.first else { return }
                                if viewModel.isWatched {
                                    withAnimation {
                                        proxy.scrollTo(first.id, anchor: .topLeading)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            .navigationDestination(for: [UpNextEpisode].self) { _ in
                VerticalUpNextListView().environmentObject(viewModel)
            }
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
            .onChange(of: shouldReload) { reload in
                if reload {
                    Task {
                        await viewModel.reload(items)
                        await MainActor.run {
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
                                       showTitle: item.showTitle,
                                       isWatched: $viewModel.isWatched)
#if os(macOS) || os(iOS)
                    .toolbar { Button("Done") { self.selectedEpisode = nil } }
#endif
                    .navigationDestination(for: ItemContent.self) { item in
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
                }
                .presentationDetents([.large])
#if os(macOS)
                .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
            }
        }
    }
    
    private func upNextCard(_ item: UpNextEpisode) -> some View {
        ZStack {
            WebImage(url: item.episode.itemImageLarge ?? item.backupImage)
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
                .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
                       height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
                .transition(.opacity)
            
            VStack(alignment: .leading) {
                Spacer()
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.4)
                        .frame(height: 50)
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
                                .frame(height: 50)
                                Rectangle()
                            }
                        }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.showTitle)
                                .font(.callout)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.leading)
                }
            }
        }
        .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
               height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: 2.5)
        .accessibilityLabel("Episode: \(item.episode.itemEpisodeNumber), of the show: \(item.showTitle).")
        .accessibilityAddTraits(.isButton)
    }
}

private struct DrawingConstants {
#if !os(tvOS)
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#else
    static let imageWidth: CGFloat = 460
    static let imageHeight: CGFloat = 260
#endif
    static let compactImageWidth: CGFloat = 200
    static let compactImageHeight: CGFloat = 120
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
