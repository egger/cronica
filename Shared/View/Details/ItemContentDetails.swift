//
//  ItemContentDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

#if os(iOS)
struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    let itemUrl: URL
    @StateObject private var viewModel: ItemContentViewModel
    @StateObject private var store = SettingsStore.shared
    @State private var showConfirmation = false
    @State private var showSeasonConfirmation = false
    @State private var switchMarkAsView = false
    @State private var showNotificationUI = false
    @State private var notificationMessage = ""
    @State private var notificationImage = ""
    @State private var showCustomList = false
    @State private var showUserNotes = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading { ProgressView() }
            VStack {
                ScrollView {
                    ViewThatFits {
                        horizontalHeader
                        verticalHeader
                    }
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    if let seasons = viewModel.content?.itemSeasons {
                        SeasonList(showID: id, numberOfSeasons: seasons).padding(0)
                    }
                    
                    
                    WatchProvidersList(id: id, type: type)
                    
                    CastListView(credits: viewModel.credits)
                    
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: nil,
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: true)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    AttributionView()
                        .padding([.top, .bottom])
                }
            }
            .background {
                if UIDevice.isIPhone {
                    TranslucentBackground(image: viewModel.content?.cardImageLarge)
                }
            }
            .task {
                await viewModel.load()
                viewModel.registerNotification()
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
                        if UIDevice.isIPad {
                            if viewModel.isInWatchlist {
                                watchButton
                                favoriteButton
                                archiveButton
                                pinButton
                                addToCustomListButton
                                openInMenu
                            }
                        } else {
                            moreMenu
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("Cancel") { }
                Button("Retry") { Task { await viewModel.load() } }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showCustomList) {
                ItemContentCustomListSelector(item: $viewModel.watchlistItem, showView: $showCustomList)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
                .appTheme()
                .appTint()
            }
            .sheet(isPresented: $showUserNotes) {
                NavigationStack {
                    if let item = viewModel.watchlistItem {
                        ReviewView(id: item.notificationID, showView: $showUserNotes)
                    }
                }
                .presentationDetents([.medium, .large])
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
            ConfirmationDialogView(showConfirmation: $showNotificationUI,
                                   message: notificationMessage, image: notificationImage)
        }
    }
    
    private var verticalHeader: some View {
        VStack {
            CoverImageView(isFavorite: $viewModel.isFavorite,
                           isWatched: $viewModel.isWatched,
                           isPin: $viewModel.isPin,
                           isArchive: $viewModel.isArchive,
                           title: title)
                .environmentObject(viewModel)
            
            DetailWatchlistButton()
                .keyboardShortcut("l", modifiers: [.option])
                .environmentObject(viewModel)
            
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title)
            .padding()
        }
    }
    
    private var horizontalHeader: some View {
        HStack {
            VStack {
                CoverImageView(isFavorite: $viewModel.isFavorite,
                               isWatched: $viewModel.isWatched,
                               isPin: $viewModel.isPin,
                               isArchive: $viewModel.isArchive,
                               title: title)
                    .environmentObject(viewModel)
                
                DetailWatchlistButton()
                    .keyboardShortcut("l", modifiers: [.option])
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
            
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title)
            .frame(minWidth: 400, idealWidth: 500, maxWidth: 500, alignment: .center)
            .padding(.trailing)
        }
    }
    
    private var addToCustomListButton: some View {
        Button {
            if viewModel.watchlistItem == nil {
                viewModel.fetchSavedItem()
            }
            showCustomList.toggle()
        } label: {
            Label("addToCustomList", systemImage: "rectangle.on.rectangle.angled")
        }
    }
    
    private var watchButton: some View {
        Button {
            animate(for: .watched)
            viewModel.update(.watched)
        } label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
        }
        .keyboardShortcut("w", modifiers: [.option])
    }
    
    private var favoriteButton: some View {
        Button {
            animate(for: .favorite)
            viewModel.update(.favorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
        .keyboardShortcut("f", modifiers: [.option])
    }
    
    private var archiveButton: some View {
        Button {
            animate(for: .archive)
            viewModel.update(.archive)
        } label: {
            Label(viewModel.isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox")
        }
    }
    
    private var pinButton: some View {
        Button {
            animate(for: .pin)
            viewModel.update(.pin)
        } label: {
            Label(viewModel.isPin ? "Unpin Item" : "Pin Item",
                  systemImage: viewModel.isPin ? "pin.slash.fill" : "pin.fill")
        }
    }
    
    private var openInMenu: some View {
        Menu {
            if viewModel.content?.hasIMDbUrl ?? false {
                Button("IMDb") {
                    guard let url = viewModel.content?.imdbUrl else { return }
                    UIApplication.shared.open(url)
                }
            }
            Button("TMDb") {
                guard let url = viewModel.content?.itemURL else { return }
                UIApplication.shared.open(url)
            }
        } label: {
            if UIDevice.isIPad {
                Label("Open in", systemImage: "ellipsis.circle")
            } else {
                Text("Open in")
            }
        }
    }
    
    private var moreMenu: some View {
        Menu {
            if viewModel.isInWatchlist {
                addToCustomListButton
                archiveButton
                pinButton
                userNotesButton
            }
            watchButton
            favoriteButton
            openInMenu
        } label: {
            Label("More Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .disabled(viewModel.isLoading ? true : false)
    }
    
    private var userNotesButton: some View {
        Button {
            showUserNotes.toggle()
        } label: {
            Label("reviewTitle", systemImage: "note.text")
        }
    }
    
    private func animate(for action: UpdateItemProperties) {
        switch action {
        case .watched:
            notificationMessage = viewModel.isWatched ? "removedFromWatched" : "markedAsWatched"
            notificationImage = viewModel.isWatched ? "minus.circle" : "checkmark.circle.fill"
        case .favorite:
            notificationMessage = viewModel.isFavorite ? "removedFromFavorites" : "markedAsFavorite"
            notificationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.circle.fill"
        case .pin:
            notificationMessage = viewModel.isPin ? "removedFromPin" : "markedAsPin"
            notificationImage = viewModel.isPin ? "pin.slash.fill" : "pin.fill"
        case .archive:
            notificationMessage = viewModel.isArchive ? "removedFromArchive" : "markedAsArchive"
            notificationImage = viewModel.isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation { showNotificationUI.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                showNotificationUI = false
                notificationMessage = ""
                notificationImage = ""
            }
        }
    }
}
#endif

#if os(iOS)
struct ItemContentDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentDetails(title: ItemContent.previewContent.itemTitle,
                           id: ItemContent.previewContent.id,
                           type: MediaType.movie)
    }
}
#endif


struct LargerCoverImage: View {
    let title: String
    let subtitle: String
    let overview: String
    let backdrop: URL?
    let poster: URL?
    var body: some View {
        HStack {
            CenterVerticalView {
                WebImage(url: poster)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            Spacer()
            CenterVerticalView {
                VStack {
                    Text(title)
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    Text(overview)
                        .lineLimit(2)
                }
            }
        }
        .background {
            ZStack {
                WebImage(url: backdrop)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                Rectangle().fill(.black.opacity(0.8))
            }
            .ignoresSafeArea(.all)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
        .shadow(radius: 5)
    }
}
