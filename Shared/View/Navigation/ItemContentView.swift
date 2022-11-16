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
    @State private var showConfirmation = false
    @State private var showSeasonConfirmation = false
    @State private var switchMarkAsView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
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
            if viewModel.isLoading {
                ProgressView()
                    .foregroundColor(.secondary)
            }
            VStack {
                ScrollView {
                    CoverImageView(title: title)
                        .environmentObject(viewModel)
                    
                    if UIDevice.isIPhone {
                        WatchlistButtonView()
                            .keyboardShortcut("l", modifiers: [.option])
                            .environmentObject(viewModel)
                    } else {
                        ViewThatFits {
                            HStack {
                                watchlistButton
                                    .keyboardShortcut("l", modifiers: [.option])
                                    .padding(.horizontal)
                                MarkAsMenuView()
                                    .environmentObject(viewModel)
                                    .buttonStyle(.bordered)
                                    .controlSize(.large)
                                    .padding(.trailing)
                            }
                            .padding([.top, .bottom])
                            watchlistButton
                                .keyboardShortcut("l", modifiers: [.option])
                        }
                    }
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
                                    title: title)
                    .padding()
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                tvId: id,
                                inWatchlist: $viewModel.isInWatchlist,
                                seasonConfirmation: $showSeasonConfirmation)
                    .padding(0)
                    
                    CastListView(credits: viewModel.credits)
                    
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "list.and.film",
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: true)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    AttributionView()
                        .padding([.top, .bottom])
                }
            }
            .background {
                if newBackgroundStyle {
                    ZStack {
                        WebImage(url: viewModel.content?.cardImageMedium)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                            .padding(.zero)
                        Rectangle()
                            .fill(.regularMaterial)
                            .ignoresSafeArea()
                            .padding(.zero)
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
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
                        if UIDevice.isIPhone {
                            MarkAsMenuView()
                                .environmentObject(viewModel)
                        }
                    }
                }
            }
            .alert("Error",
                   isPresented: $viewModel.showErrorAlert,
                   actions: {
                Button("Cancel") {
                    
                }
                Button("Retry") {
                    Task {
                        await viewModel.load()
                    }
                }
            }, message: {
                Text(viewModel.errorMessage)
            })
            ConfirmationDialogView(showConfirmation: $showConfirmation)
            ConfirmationDialogView(showConfirmation: $showSeasonConfirmation,
                                   message: "Season Marked as Watched", image: "tv.fill")
        }
    }
    private var watchlistButton: some View {
        Button(action: {
            if let item = viewModel.content {
                viewModel.updateWatchlist(with: item)
            }
        }, label: {
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
        })
        .buttonStyle(.bordered)
        .tint(viewModel.isInWatchlist ? .red : .blue)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(title: ItemContent.previewContent.itemTitle,
                        id: ItemContent.previewContent.id,
                        type: MediaType.movie)
    }
}
