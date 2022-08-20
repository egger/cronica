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
            VStack {
                ScrollView {
                    CoverImageView(title: title)
                        .environmentObject(viewModel)
                    
                    if UIDevice.isIPhone {
                        WatchlistButtonView()
                            .keyboardShortcut("l", modifiers: [.option])
                            .environmentObject(viewModel)
                    } else {
                        HStack {
                            WatchlistButtonView()
                                .keyboardShortcut("l", modifiers: [.option])
                                .environmentObject(viewModel)
                                .padding(.leading)
                            MarkAsMenuView()
                                .environmentObject(viewModel)
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .padding(.trailing)
                        }
                        .padding([.top, .bottom])
                    }
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
                                    title: title)
                    .padding()
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonsView(numberOfSeasons: viewModel.content?.itemSeasons,
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
#if DEBUG
                        Button(action: {
                            print("Print object '\(title)': \(viewModel.content as Any)")
                        }, label: {
                            Label("Print object", systemImage: "curlybraces.square.fill")
                        })
                        .tint(.orange)
#endif
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
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(title: ItemContent.previewContent.itemTitle,
                        id: ItemContent.previewContent.id,
                        type: MediaType.movie)
    }
}
