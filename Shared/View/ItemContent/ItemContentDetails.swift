//
//  ItemContentDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI
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
                ItemContentPadView(id: id, title: title, type: type, showConfirmation: $showConfirmation)
                    .environmentObject(viewModel)
#elseif os(iOS)
                if UIDevice.isIPad {
                    ItemContentPadView(id: id, title: title, type: type, showConfirmation: $showConfirmation)
                        .environmentObject(viewModel)
                } else {
                    ItemContentPhoneView(title: title, type: type, id: id, showConfirmation: $showConfirmation)
                        .environmentObject(viewModel)
                }
#endif
            }
            .background {
                TranslucentBackground(image: viewModel.content?.cardImageLarge)
            }
            .task {
                await viewModel.load()
                viewModel.registerNotification()
                viewModel.checkIfAdded()
            }
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
            .toolbar {
#if os(iOS)
                ToolbarItem {
                    HStack {
                        shareButton
                            .disabled(viewModel.isLoading ? true : false)
                        moreMenu
                    }
                }
#elseif os(macOS)
                if handleToolbarOnPopup {
                    ToolbarItem(placement: .status) {
                        ViewThatFits {
                            HStack {
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
                                watchButton
                                favoriteButton
                                archiveButton
                                pinButton
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
                NavigationStack {
                    if let contentID = viewModel.content?.itemContentID {
                        ItemContentCustomListSelector(contentID: contentID,
                                                      showView: $showCustomList,
                                                      title: title)
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
#if os(macOS)
                .frame(width: 500, height: 600, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
            .sheet(isPresented: $showUserNotes) {
                if let contentID = viewModel.content?.itemContentID {
                    NavigationStack {
                        ReviewView(id: contentID, showView: $showUserNotes)
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
            ConfirmationDialogView(showConfirmation: $showNotificationUI,
                                   message: notificationMessage, image: notificationImage)
#elseif os(tvOS)
            ItemContentTVView(title: title, type: type, id: id)
                .environmentObject(viewModel)
#endif
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
            if let homepage = viewModel.content?.homepage {
                Button("Official Website") {
                    guard let url = URL(string: homepage) else { return }
                    UIApplication.shared.open(url)
                }
            }
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
                #if os(iOS)
                if UIDevice.isIPhone {
                    addToCustomListButton
                }
                #else
                addToCustomListButton
                #endif
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
        NavigationStack {
            ItemContentDetails(title: ItemContent.example.itemTitle,
                               id: ItemContent.example.id,
                               type: .movie)
        }
    }
}
