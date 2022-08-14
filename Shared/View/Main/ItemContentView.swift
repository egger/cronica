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
                    
                    ViewThatFits {
                        HStack {
                            WatchlistButtonView()
                                .keyboardShortcut("l", modifiers: [.option])
                                .environmentObject(viewModel)
                                .frame(width: 260)
                                .padding(.leading)
                            MarkAsMenuView()
                                .environmentObject(viewModel)
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .frame(width: 260)
                                .padding(.trailing)
                        }
                        .padding([.top, .bottom])
                        
                        WatchlistButtonView()
                            .keyboardShortcut("l", modifiers: [.option])
                            .environmentObject(viewModel)
                    }
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
                                    title: title)
                    .padding()
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonsView(numberOfSeasons: viewModel.content?.itemSeasons,
                                tvId: id)
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
                        if horizontalSizeClass == .compact {
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

struct MarkAsMenuView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var body: some View {
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
#if targetEnvironment(simulator)
            Button(action: {
                print(viewModel.content?.itemStatus as Any)
            }, label: {
                Label("Print object", systemImage: "ellipsis.curlybraces")
            })
#endif
        }, label: {
            if horizontalSizeClass == .compact {
                Label("Mark as", systemImage: "ellipsis")
            } else {
                Text("Mark as")
            }
        })
        .disabled(viewModel.isLoading ? true : false)
    }
}
