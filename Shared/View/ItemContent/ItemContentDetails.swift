//
//  ItemContentDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
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
#if os(macOS)
    var handleToolbarOnPopup: Bool = false
#endif
    init(title: String, id: Int, type: MediaType, handleToolbar: Bool = false) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
#if os(macOS)
        self.handleToolbarOnPopup = handleToolbar
#endif
    }
    var body: some View {
        ZStack {
#if os(macOS) || os(iOS)
            if viewModel.isLoading { ProgressView().padding() }
            ScrollView {
#if os(macOS)
                macOS
#elseif os(iOS)
                iOS
#endif
            }
            .background {
#if os(iOS)
                if UIDevice.isIPhone {
                    TranslucentBackground(image: viewModel.content?.cardImageLarge)
                }
#endif
            }
            .task {
                await viewModel.load()
                viewModel.registerNotification()
            }
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
            .navigationTitle(title)
            .toolbar {
#if os(iOS)
                ToolbarItem {
                    HStack {
                        notificationStatus
                        shareButton
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
#elseif os(macOS)
                if handleToolbarOnPopup {
                    ToolbarItem(placement: .status) {
                        ViewThatFits {
                            HStack {
                                Button { } label: {
                                    notificationStatus
                                }
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
                                Button { } label: {
                                    notificationStatus
                                }
                                watchButton
                                favoriteButton
                                if viewModel.isInWatchlist {
                                    addToCustomListButton
                                        .sheet(isPresented: $showCustomList) {
                                            ItemContentCustomListSelector(item: $viewModel.watchlistItem, showView: $showCustomList)
                                                .presentationDetents([.medium])
                                                .frame(width: 500, height: 600, alignment: .center)
                                        }
                                }
                                shareButton
                            }
                            shareButton
                        }
                        
                    }
                }
#endif
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
                        ReviewView(id: item.itemContentID, showView: $showUserNotes)
                    }
                }
                .presentationDetents([.medium, .large])
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
            ConfirmationDialogView(showConfirmation: $showNotificationUI,
                                   message: notificationMessage, image: notificationImage)
#elseif os(tvOS)
            tvOS
#endif
        }
    }
    
#if os(macOS)
    var macOS: some View {
        VStack {
            LargerHeader(title: title, type: type)
                .environmentObject(viewModel)
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, numberOfSeasons: seasons).padding(.zero)
            }
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            ItemContentListView(items: viewModel.recommendations,
                                title: "Recommendations",
                                subtitle: "You may like",
                                addedItemConfirmation: $showConfirmation,
                                displayAsCard: true)
            
            InformationSectionView(item: viewModel.content)
                .padding()
            
            AttributionView()
        }
    }
#endif
    
#if os(tvOS)
    private var tvOS: some View {
        ScrollView {
            TVHeader(title: title, type: type)
                .environmentObject(viewModel)
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
            VStack {
                ScrollView {
                    if let seasons = viewModel.content?.itemSeasons {
                        SeasonList(showID: id, numberOfSeasons: seasons)
                    }
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "",
                                        image: nil,
                                        addedItemConfirmation: .constant(false),
                                        displayAsCard: true)
                    CastListView(credits: viewModel.credits)
                        .padding(.bottom)
                    AttributionView()
                }
            }
            .task { await viewModel.load() }
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
        }
        .ignoresSafeArea()
    }
#endif
    
#if os(iOS)
    var iOS: some View {
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
#endif
    
#if os(iOS)
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
#endif
    
    private var notificationStatus: some View {
        Image(systemName: viewModel.hasNotificationScheduled ? "bell.fill" : "bell")
            .opacity(viewModel.isNotificationAvailable ? 1 : 0)
            .foregroundColor(.accentColor)
            .accessibilityHidden(true)
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
#if os(iOS) || os(macOS)
        .keyboardShortcut("w", modifiers: [.option])
#endif
    }
    
    private var favoriteButton: some View {
        Button {
            animate(for: .favorite)
            viewModel.update(.favorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
#if os(iOS) || os(macOS)
        .keyboardShortcut("f", modifiers: [.option])
#endif
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
    
#if os(iOS)
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
#endif
    
#if os(iOS) || os(macOS)
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
#if os(iOS)
            openInMenu
#endif
        } label: {
            Label("More Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .disabled(viewModel.isLoading ? true : false)
    }
#endif
    
    private var userNotesButton: some View {
        Button {
            showUserNotes.toggle()
        } label: {
            Label("reviewTitle", systemImage: "note.text")
        }
    }
    
    @ViewBuilder
    private var shareButton: some View {
#if os(iOS) || os(macOS)
        if let url = viewModel.content?.itemURL {
            ShareLink(item: url)
        }
#endif
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

struct ItemContentDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentDetails(title: ItemContent.example.itemTitle,
                           id: ItemContent.example.id,
                           type: .movie)
    }
}
