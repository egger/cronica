//
//  ItemContentDetailsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentDetailsView: View {
    let id: Int
    let title: String
    let type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showConfirmation = false
    @State private var showSeasonConfirmation = false
    private var itemUrl: URL
    @State private var actionMessageConfirmation = ""
    @State private var actionImageConfirmation = ""
    @State private var showActionConfirmation = false
    var handleToolbarOnPopup = false
    @State private var showCustomList = false
    init(id: Int, title: String, type: MediaType, handleToolbarOnPopup: Bool = false) {
        self.id = id
        self.title = title
        self.type = type
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
        self.handleToolbarOnPopup = handleToolbarOnPopup
       
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading { ProgressView() }
            VStack {
                ScrollView {
                    headerView
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                tvId: id,
                                inWatchlist: $viewModel.isInWatchlist,
                                seasonConfirmation: $showSeasonConfirmation)
                    .padding(.zero)
                    
                    WatchProvidersList(id: id, type: type)
                    
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
                }
            }
            .task {
                await viewModel.load()
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { item in
                PersonDetailsView(title: item.name, id: item.id)
            }
            .toolbar {
                if handleToolbarOnPopup {
                    ToolbarItem(placement: .status) {
                        ViewThatFits {
                            HStack {
                                notificationButton
                                watchButton
                                favoriteButton
                                shareButton
                            }
                            shareButton
                        }
                        
                    }
                } else {
                    ToolbarItem {
                        ViewThatFits {
                            HStack {
                                notificationButton
                                watchButton
                                favoriteButton
                                shareButton
                            }
                            shareButton
                        }
                        
                    }
                }
            }
            .navigationTitle(title)
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "markedAsWatched")
            ConfirmationDialogView(showConfirmation: $showSeasonConfirmation,
                                   message: "Season Marked as Watched")
            ConfirmationDialogView(showConfirmation: $showActionConfirmation,
                                   message: actionMessageConfirmation,
                                   image: actionImageConfirmation)
        }
        .background {
            TranslucentBackground(image: viewModel.content?.cardImageLarge)
        }
    }
    
    private var watchButton: some View {
        Button(action: {
            if viewModel.isWatched {
                actionMessageConfirmation = "removedFromWatched"
                actionImageConfirmation = "minus.circle"
            } else {
                actionMessageConfirmation = "markedAsWatched"
                actionImageConfirmation = "checkmark.circle"
            }
            viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
            showActionConfirmation.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    showActionConfirmation = false
                    actionMessageConfirmation = ""
                    actionImageConfirmation = ""
                }
            }
        }, label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
        })
        .keyboardShortcut("w", modifiers: [.option])
        .disabled(viewModel.isLoading ? true : false)
    }
    
    private var favoriteButton: some View {
        Button {
            if viewModel.isFavorite {
                actionMessageConfirmation = "removedFromFavorites"
                actionImageConfirmation = "heart.circle.fill"
            } else {
                actionMessageConfirmation = "markedAsFavorite"
                actionImageConfirmation = "heart.circle"
            }
            viewModel.updateMarkAs(markAsFavorite: !viewModel.isFavorite)
            showActionConfirmation.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    showActionConfirmation = false
                    actionMessageConfirmation = ""
                    actionImageConfirmation = ""
                }
            }
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
        .keyboardShortcut("f", modifiers: [.option])
        .disabled(viewModel.isLoading ? true : false)
    }
    
    private var shareButton: some View {
        ShareLink(item: itemUrl)
    }
    
    private var notificationButton: some View {
        Button {
             
        } label: {
            Image(systemName: viewModel.hasNotificationScheduled ? "bell.fill" : "bell")
                .opacity(viewModel.isNotificationAvailable ? 1 : 0)
                .accessibilityHidden(true)
                .accessibilityLabel(viewModel.hasNotificationScheduled ? "Notification scheduled." : "No notification scheduled.")
        }
    }
    
    private var headerView: some View {
        WebImage(url: viewModel.content?.cardImageOriginal)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(Color.gray.gradient)
                    Image(systemName: type == .tvShow ? "tv" : "film")
                        .foregroundColor(.secondary)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .frame(height: 500)
                .padding(.zero)
            }
            .aspectRatio(contentMode: .fill)
            .overlay {
                ZStack {
                    if viewModel.content?.cardImageOriginal != nil {
                        VStack {
                            Spacer()
                            ZStack(alignment: .bottom) {
                                Color.black.opacity(0.8)
                                    .frame(height: 150)
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
                                    .frame(height: 140)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                        .frame(height: 150)
                                    }
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack {
                                Text(title)
                                    .lineLimit(1)
                                    .font(.title)
                                    .foregroundColor(.white)
                                GlanceInfo(info: viewModel.content?.itemInfo)
                                    .padding(.bottom, 6)
                                    .foregroundColor(.white.opacity(0.8))
                                WatchlistButtonView()
                                    .environmentObject(viewModel)
                            }
                            .frame(maxWidth: 600)
                            .padding(.horizontal)
                            Spacer()
                            OverviewBoxView(overview: viewModel.content?.itemOverview,
                                            title: "About",
                                            type: .movie)
                            .foregroundColor(.white)
                            .padding([.horizontal, .top])
                            .frame(maxWidth: 500)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .transition(.scale)
    }
}

struct ItemContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentDetailsView(id: ItemContent.previewContent.id,
                               title: ItemContent.previewContent.itemTitle,
                               type: ItemContent.previewContent.itemContentMedia)
    }
}

struct GlanceInfo: View {
    var info: String?
    var body: some View {
        if let info {
            Text(info)
                .font(.callout)
        }
    }
}
