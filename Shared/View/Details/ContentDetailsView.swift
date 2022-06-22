//
//  ContentDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ContentDetailsView: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ContentDetailsViewModel
    @StateObject private var store: SettingsStore
    @State private var isNotificationAvailable = false
    @State private var isNotificationScheduled = false
    @State private var isInWatchlist = false
    @State private var isLoading = true
    @State private var markAsMenuVisibility = false
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var animateGesture = false
    @State private var showConfirmation = false
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ContentDetailsViewModel())
        _store = StateObject(wrappedValue: SettingsStore())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    CoverImageView(isWatched: $isWatched,
                                   isFavorite: $isFavorite,
                                   animateGesture: $animateGesture,
                                   image: viewModel.content?.cardImageMedium,
                                   title: title,
                                   isAdult: viewModel.content?.adult ?? false)
                        .environmentObject(store)
                        .onTapGesture(count: 2) {
                            withAnimation {
                                animateGesture.toggle()
                            }
                            if !isInWatchlist {
                                viewModel.update(markAsWatched: nil, markAsFavorite: nil)
                                withAnimation {
                                    isInWatchlist.toggle()
                                    isNotificationScheduled.toggle()
                                }
                            }
                            if store.gesture == .favorite {
                                isFavorite.toggle()
                                viewModel.update(markAsWatched: nil, markAsFavorite: isFavorite)
                            } else {
                                isWatched.toggle()
                                viewModel.update(markAsWatched: isWatched, markAsFavorite: nil)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation {
                                    animateGesture = false
                                }
                            }
                        }
                    
                    GlanceInfo(info: viewModel.content?.itemInfo)
                    
                    watchlistButton
                    
                    OverviewBoxView(overview: viewModel.content?.overview,
                                    title: title,
                                    type: .movie)
                        .padding()
                    
                    TrailerView(imageUrl: viewModel.content?.cardImageMedium,
                                trailerUrl: viewModel.content?.itemTrailer)
                    
                    SeasonsView(numberOfSeasons: viewModel.content?.itemSeasons, tvId: id)
                        .padding(0)
                    
                    CastListView(credits: viewModel.content?.credits)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    if let filmography = viewModel.content?.recommendations {
                        ItemContentListView(items: filmography.results,
                                            title: "Recommendations",
                                            subtitle: "You may like",
                                            image: "list.and.film",
                                            addedItemConfirmation: $showConfirmation)
                    }
                    
                    AttributionView()
                        .padding([.top, .bottom])
                }
            }
            .task { load() }
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay(overlayView)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Image(systemName: isNotificationScheduled ? "bell.fill" : "bell")
                            .opacity(isNotificationAvailable ? 1 : 0)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        ShareLink(item: URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!)
                            .disabled(isLoading ? true : false)
                        if markAsMenuVisibility {
                            markAsMenu
                        }
                    }
                }
            }
             ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
    
    var watchlistButton: some View {
        Button(action: {
            withAnimation {
                isInWatchlist.toggle()
            }
            viewModel.update(markAsWatched: nil, markAsFavorite: nil)
            if !isInWatchlist {
                withAnimation {
                    isNotificationScheduled = viewModel.content?.itemCanNotify ?? false
                }
            } else {
                withAnimation {
                    isNotificationScheduled.toggle()
                }
            }
        }, label: {
            Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: isInWatchlist ? "minus.square" : "plus.square")
        })
        .buttonStyle(.bordered)
        .tint(isInWatchlist ? .red : .blue)
        .controlSize(.large)
        .disabled(isLoading)
        .keyboardShortcut("w", modifiers: [.command, .shift])
    }
    
    private var markAsMenu: some View {
        Menu(content: {
            Button(action: {
                isWatched.toggle()
                if !isInWatchlist {
                    withAnimation {
                        isInWatchlist.toggle()
                        isNotificationScheduled = viewModel.content?.itemCanNotify ?? false
                    }
                }
                viewModel.update(markAsWatched: isWatched, markAsFavorite: nil)
            }, label: {
                Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: isWatched ? "minus.circle" : "checkmark.circle")
            })
            .keyboardShortcut("m", modifiers: [.command, .shift])
            Button(action: {
                isFavorite.toggle()
                if !isInWatchlist {
                    withAnimation {
                        isInWatchlist.toggle()
                    }
                }
                viewModel.update(markAsWatched: nil, markAsFavorite: isFavorite)
            }, label: {
                Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }, label: {
            Label("More", systemImage: "ellipsis")
        })
        .disabled(isLoading ? true : false)
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .failure(let error):
            ZStack {
                RetryView(text: error.localizedDescription, retryAction: {
                    Task {
                        await viewModel.load(id: self.id, type: self.type)
                    }
                })
            }
            .padding()
            .background(.regularMaterial)
        default:
            EmptyView()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
            if viewModel.content != nil {
                isInWatchlist = viewModel.context.isItemInList(id: self.id, type: self.type)
                if isInWatchlist {
                    withAnimation {
                        isNotificationScheduled = viewModel.context.isNotificationScheduled(id: self.id)
                        isWatched = viewModel.context.isMarkedAsWatched(id: self.id)
                        isFavorite = viewModel.context.isMarkedAsFavorite(id: self.id)
                    }
                }
                withAnimation {
                    isNotificationAvailable = viewModel.content?.itemCanNotify ?? false
                    if viewModel.content?.itemStatus == .released {
                        markAsMenuVisibility = true
                    }
                    isLoading = false
                }
            }
        }
    }
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailsView(title: ItemContent.previewContent.itemTitle,
                           id: ItemContent.previewContent.id,
                           type: MediaType.movie)
    }
}

private struct GlanceInfo: View {
    let info: String?
    var body: some View {
        if let info {
            Text(info)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
