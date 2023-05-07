//
//  UpNextListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import CoreData

struct UpNextListView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @State private var isWatched = false
    @Binding var shouldReload: Bool
    @State private var viewModel = UpNextViewModel()
    @State private var selectedEpisode: UpNextEpisode?
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !viewModel.listItems.isEmpty {
                    NavigationLink(value: viewModel.listItems) {
                        TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: true)
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(viewModel.listItems) { item in
                                UpNextItem(item: item)
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == viewModel.listItems.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == viewModel.listItems.last!.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
                                    .onTapGesture { selectedEpisode = item }
                            }
                        }
                    }
                }
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            .navigationDestination(for: [UpNextEpisode].self) { item in
                DetailedUpNextView()
                    .environmentObject(viewModel)
            }
            .task {
                await viewModel.load(items)
            }
            .onChange(of: shouldReload) { reload in
                if reload {
                    viewModel.isLoaded = false
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            viewModel.listItems.removeAll()
                        }
                    }
                    Task {
                        await viewModel.load(items)
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                shouldReload = false
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
                    guard let episode = selectedEpisode?.episode else { return }
                    await viewModel.handleWatched(episode)
                     selectedEpisode = nil
                }
            }
        }
    }
}
