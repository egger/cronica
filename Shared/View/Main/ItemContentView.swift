//
//  ItemContentView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ItemContentView: View {
    var title: String
    var id: Int
    var type: MediaType
    let itemUrl: URL
    @StateObject private var viewModel: ItemContentViewModel
    @StateObject private var store: SettingsStore
    @State private var markAsMenuVisibility = false
    @State private var animateGesture = false
    @State private var showConfirmation = false
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        _store = StateObject(wrappedValue: SettingsStore())
        self.title = title
        self.id = id
        self.type = type
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    CoverImageView(isWatched: $viewModel.isWatched,
                                   isFavorite: $viewModel.isFavorite,
                                   animateGesture: $animateGesture,
                                   image: viewModel.content?.cardImageMedium,
                                   title: title,
                                   isAdult: viewModel.content?.adult ?? false)
                        .environmentObject(store)
                        .onTapGesture(count: 2) {
                            withAnimation {
                                animateGesture.toggle()
                            }
                            if !viewModel.isInWatchlist {
                                viewModel.update()
                                withAnimation {
                                    viewModel.isInWatchlist.toggle()
                                    viewModel.hasNotificationScheduled.toggle()
                                }
                            }
                            if store.gesture == .favorite {
                                viewModel.isFavorite.toggle()
                                viewModel.update(markAsFavorite: viewModel.isFavorite)
                            } else {
                                viewModel.isWatched.toggle()
                                viewModel.update(markAsWatched: viewModel.isWatched)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation {
                                    animateGesture = false
                                }
                            }
                        }
                    
                    GlanceInfo(info: viewModel.content?.itemInfo)
                    
                    watchlistButton
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
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
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
            .overlay(overlayView)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Image(systemName: viewModel.hasNotificationScheduled ? "bell.fill" : "bell")
                            .opacity(viewModel.isNotificationAvailable ? 1 : 0)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        ShareLink(item: itemUrl)
                            .disabled(viewModel.isLoading ? true : false)
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
                viewModel.isInWatchlist.toggle()
            }
            viewModel.update()
            if !viewModel.isInWatchlist {
                withAnimation {
                    viewModel.hasNotificationScheduled = viewModel.content?.itemCanNotify ?? false
                }
            } else {
                withAnimation {
                    viewModel.hasNotificationScheduled.toggle()
                }
            }
        }, label: {
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
        })
        .buttonStyle(.bordered)
        .tint(viewModel.isInWatchlist ? .red : .blue)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
        .keyboardShortcut("w", modifiers: [.command, .shift])
    }
    
    private var markAsMenu: some View {
        Menu(content: {
            Button(action: {
                viewModel.isWatched.toggle()
                if !viewModel.isInWatchlist {
                    withAnimation {
                        viewModel.isInWatchlist.toggle()
                        viewModel.hasNotificationScheduled = viewModel.content?.itemCanNotify ?? false
                    }
                }
                viewModel.update(markAsWatched: viewModel.isWatched)
            }, label: {
                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
            })
            .keyboardShortcut("m", modifiers: [.command, .shift])
            Button(action: {
                viewModel.isFavorite.toggle()
                if !viewModel.isInWatchlist {
                    withAnimation {
                        viewModel.isInWatchlist.toggle()
                    }
                }
                viewModel.update(markAsFavorite: viewModel.isFavorite)
            }, label: {
                Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }, label: {
            Label("More", systemImage: "ellipsis")
        })
        .disabled(viewModel.isLoading ? true : false)
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if let error = viewModel.errorMessage {
            ZStack {
                RetryView(message: error, retryAction: {
                    Task {
                        await viewModel.load()
                    }
                })
            }
            .padding()
            .background(.regularMaterial)
        }
    }
    
    private func load() {
        Task {
            await self.viewModel.load()
            if viewModel.content != nil {
                withAnimation {
                    if viewModel.content?.itemStatus == .released {
                        markAsMenuVisibility = true
                    }
                }
            }
        }
    }
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(title: ItemContent.previewContent.itemTitle,
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
