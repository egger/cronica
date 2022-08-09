//
//  ItemContentView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentView: View {
    var title: String
    var id: Int
    var type: MediaType
    let itemUrl: URL
    @StateObject private var viewModel: ItemContentViewModel
    @StateObject private var store: SettingsStore
    @State private var animateGesture = false
    @State private var showConfirmation = false
    @State private var switchMarkAsView = false
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
                                   image: UIDevice.isIPad ? viewModel.content?.cardImageLarge : viewModel.content?.cardImageMedium,
                                   title: title,
                                   isAdult: viewModel.content?.adult ?? false, glanceInfo: viewModel.content?.itemInfo)
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
                    
                    if UIDevice.isIPad {
                        HStack {
                            watchlistButton
                            if viewModel.showMarkAsButton {
                                markAsMenu
                                    .controlSize(.large)
                                    .buttonStyle(.bordered)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        watchlistButton
                            .onAppear {
                                withAnimation {
                                    switchMarkAsView.toggle()
                                }
                            }
                    }
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
                                    title: title,
                                    type: .movie)
                    .padding()
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonsView(numberOfSeasons: viewModel.content?.itemSeasons, tvId: id)
                        .padding(0)
                    
                    CastListView(credits: viewModel.credits)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "list.and.film",
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: true)
                    
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
                        if switchMarkAsView { markAsMenu }
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
        .keyboardShortcut("l", modifiers: [.option])
    }
    
    private var markAsMenu: some View {
        Menu(content: {
            Button(action: {
                viewModel.update(markAsWatched: viewModel.isWatched)
            }, label: {
                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
            })
            .keyboardShortcut("w", modifiers: [.option])
            Button(action: {
                viewModel.update(markAsFavorite: viewModel.isFavorite)
            }, label: {
                Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .keyboardShortcut("f", modifiers: [.option])
        }, label: {
            if switchMarkAsView {
                Label("Mark as", systemImage: "ellipsis")
            } else {
                Text("Mark as")
            }
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

private struct ScoreSection: View {
    var body: some View {
        Section {
            
        } header: {
            Label("Score", systemImage: "")
        }
    }
}


private struct HorizontalInformationView: View {
    var body: some View {
        EmptyView()
    }
}
