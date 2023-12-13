//
//  ItemContentDetails.swift
//  Cronica
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel = ItemContentViewModel()
    @StateObject private var store = SettingsStore.shared
    @State private var showPopup = false
    @State private var showSeasonConfirmation = false
    @State private var switchMarkAsView = false
    @State private var showCustomList = false
    @State private var showUserNotes = false
    @State private var popupType: ActionPopupItems?
    @State private var showReleaseDateInfo = false
    @State private var animateGesture = false
    @State private var animationImage = ""
    // MARK: View properties for sizeBasedPadMacView
    @State private var isSideInfoPanelShowed = false
    @State private var showInfoBox = false
    @State private var showOverview = false
    var handleToolbar = false
    var body: some View {
        VStack {
            ScrollView {
#if os(macOS)
                sizeBasedPadMacView
#elseif os(iOS)
                if UIDevice.isIPad {
                    sizeBasedPadMacView
                } else {
                    sizedBasedPhoneView
                }
#elseif os(tvOS)
                ItemContentTVView(title: title, type: type, id: id)
                    .environmentObject(viewModel)
#endif
            }
        }
#if !os(tvOS)
        .toolbar {
#if os(iOS)
            if UIDevice.isIPad {
                ToolbarItem {
                    HStack {
                        if viewModel.isInWatchlist {
                            favoriteButtonToolbar
                            archiveButtonToolbar
                            pinButtonToolbar
                            reviewButtonToolbar
                        }
                        shareButton
                        moreMenu
                    }
                    .disabled(viewModel.isLoading ? true : false)
                }
            } else {
                ToolbarItem {
                    HStack {
                        shareButton
                        moreMenu
                    }
                    .disabled(viewModel.isLoading ? true : false)
                }
            }
#else
            if handleToolbar {
                ToolbarItem(placement: .status) { toolbarRow }
            } else {
                ToolbarItem { toolbarRow }
            }
#endif
        }
#endif
        .overlay { if viewModel.isLoading { ProgressView().padding().unredacted() } }
        .background {
            TranslucentBackground(image: viewModel.showPoster ? viewModel.content?.posterImageLarge : viewModel.content?.cardImageLarge)
        }
        .task {
            await viewModel.load(id: id, type: type)
            viewModel.registerNotification()
            viewModel.checkIfAdded()
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("Cancel") { }
            Button("Retry") { Task { await viewModel.load(id: id, type: type) } }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showCustomList) {
            NavigationStack {
                if let contentID = viewModel.content?.itemContentID {
                    ItemContentCustomListSelector(contentID: contentID,
                                                  showView: $showCustomList,
                                                  title: title, image: viewModel.content?.cardImageSmall)
                }
            }
            .onDisappear {
                viewModel.checkListStatus()
            }
            .presentationDetents([.large])
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
                .presentationDetents([.large])
#if os(macOS)
                .frame(width: 500, height: 500, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
        }
        .sheet(isPresented: $showReleaseDateInfo) {
            let productionRegion = viewModel.content?.productionCountries?.first?.iso31661 ?? "US"
            DetailedReleaseDateView(item: viewModel.content?.releaseDates?.results,
                                    productionRegion: productionRegion,
                                    dismiss: $showReleaseDateInfo)
        }
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }
    
    //    private var addToCustomListButton: some View {
    //        Button("Add To List", systemImage: "rectangle.on.rectangle.angled") {
    //            showCustomList.toggle()
    //        }
    //    }
    
#if os(iOS)
    private var sizedBasedPhoneView: some View {
        VStack {
            if viewModel.showPoster || store.usePostersAsCover {
                poster
            } else {
                cover
            }
            
            Text(title)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
                .unredacted()
            if let genres = viewModel.content?.itemGenres, !genres.isEmpty {
                Text(genres)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
            }
            if let info = viewModel.content?.itemQuickInfo, !info.isEmpty {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
            }
            
            HStack {
                if type == .movie {
                    watchButton
                        .padding(.leading)
                } else {
                    favoriteButton
                }
                DetailWatchlistButton(showCustomList: $showCustomList)
                    .keyboardShortcut("l", modifiers: [.option])
                    .environmentObject(viewModel)
                    .padding(.horizontal)
                listButton
                    .padding(.trailing)
            }
            .padding(.top)
            
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title).padding()
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonListView(showID: id, showTitle: title, numberOfSeasons: seasons, isInWatchlist: $viewModel.isInWatchlist, showCover: viewModel.content?.cardImageMedium)
                    .padding([.top, .horizontal], .zero)
                    .padding(.bottom)
            }
            
            WatchProvidersList(id: id, type: type)
            
            TrailerListView(trailers: viewModel.trailers)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                          title: NSLocalizedString("Recommendations", comment: ""),
                                          showPopup: $showPopup,
                                          popupType: $popupType,
                                          displayAsCard: true)
            
            infoBox(item: viewModel.content, type: type).padding()
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack { }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .actionPopup(isShowing: $showPopup, for: popupType)
    }
#endif
    
#if !os(tvOS)
    private var sizeBasedPadMacView: some View {
        VStack {
            
            // Header
            HStack {
                poster
                
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(.bottom)
                    HStack {
                        Text(viewModel.content?.itemOverview ?? "")
                            .lineLimit(10)
                            .onTapGesture {
                                showOverview.toggle()
                            }
                        Spacer()
                    }
                    .frame(maxWidth: 460)
                    .padding(.bottom)
                    .popover(isPresented: $showOverview) {
                        if let overview = viewModel.content?.itemOverview {
                            VStack {
                                ScrollView {
                                    Text(overview)
                                        .padding()
                                }
                            }
                            .frame(minWidth: 200, maxWidth: 400, minHeight: 200, maxHeight: 300, alignment: .center)
                        }
                    }
                    
                    // Actions
                    HStack {
                        DetailWatchlistButton(showCustomList: $showCustomList)
                            .environmentObject(viewModel)
                        
                        if viewModel.isInWatchlist {
                            if type == .movie {
                                watchButton
                            } else {
                                favoriteButton
                            }
                            
                            listButton
                        }
                    }
                }
                .frame(width: 360)
                
                ViewThatFits {
                    QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                        .frame(width: 280)
                        .padding(.horizontal)
                        .onAppear {
                            showInfoBox = false
                            isSideInfoPanelShowed = true
                        }
                        .onDisappear {
                            showInfoBox = true
                            isSideInfoPanelShowed = false
                        }
                    VStack {
                        Text("")
                    }
                }
                
                Spacer()
            }
            .padding(.leading)
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonListView(showID: id, showTitle: title,
                               numberOfSeasons: seasons, isInWatchlist: $viewModel.isInWatchlist, showCover: viewModel.content?.cardImageMedium).padding(0)
            }
            
            TrailerListView(trailers: viewModel.trailers)
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                          title: "Recommendations",
                                          showPopup: $showPopup,
                                          popupType: $popupType,
                                          displayAsCard: true)
            if showInfoBox {
                GroupBox("Information") {
                    QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                }
                .padding()
                
            }
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
        .navigationTitle(title)
#endif
        .task {
            if !isSideInfoPanelShowed && !showInfoBox { showInfoBox = true }
        }
    }
#endif
    
    private var poster: some View {
        WebImage(url: viewModel.content?.posterImageMedium)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    VStack {
                        Image(systemName: "popcorn.fill")
                            .font(.title)
                            .fontWidth(.expanded)
                            .foregroundColor(.white.opacity(0.8))
                            .unredacted()
                            .padding()
                    }
                    .frame(width: 220, height: 300)
                    .padding()
                }
            }
            .overlay {
                ZStack {
                    Rectangle().fill(.thinMaterial)
                    Image(systemName: animationImage)
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120, alignment: .center)
                        .scaleEffect(animateGesture ? 1.1 : 1)
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: DrawingConstants.posterWidth, height: DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onTapGesture(count: 2) {
                animate(for: store.gesture)
                viewModel.update(store.gesture)
            }
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
            .padding()
            .accessibility(hidden: true)
    }
    
#if os(iOS)
    private var cover: some View {
        HeroImage(url: viewModel.content?.cardImageLarge,
                  title: title)
        .overlay {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Image(systemName: animationImage)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120, alignment: .center)
                    .scaleEffect(animateGesture ? 1.1 : 1)
            }
            .opacity(animateGesture ? 1 : 0)
        }
        .frame(width: DrawingConstants.coverWidth, height: DrawingConstants.coverHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        .padding(.top)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibility(hidden: true)
        .onTapGesture(count: 2) {
            animate(for: store.gesture)
            viewModel.update(store.gesture)
        }
    }
#endif
    
    @ViewBuilder
    private func infoBox(item: ItemContent?, type: MediaType) -> some View {
        GroupBox("Information") {
            Section {
                infoView(title: NSLocalizedString("Original Title", comment: ""),
                         content: item?.originalItemTitle)
                if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                    infoView(title: NSLocalizedString("Overview", comment: ""),
                             content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
                }
                infoView(title: NSLocalizedString("Run Time", comment: ""),
                         content: item?.itemRuntime)
                if type == .movie {
                    if let theatricalStringDate = item?.itemTheatricalString {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Release Date")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(theatricalStringDate)
                                    .lineLimit(1)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            Spacer()
                        }
                        .padding([.horizontal, .top], 2)
                        .onTapGesture {
                            showReleaseDateInfo.toggle()
                        }
                    }
                    
                } else {
                    infoView(title: NSLocalizedString("First Air Date",
                                                      comment: ""),
                             content: item?.itemFirstAirDate)
                }
                infoView(title: NSLocalizedString("Ratings Score", comment: ""),
                         content: item?.itemRating)
                infoView(title: NSLocalizedString("Status",
                                                  comment: ""),
                         content: item?.itemStatus.localizedTitle)
                infoView(title: NSLocalizedString("Genres", comment: ""),
                         content: item?.itemGenres)
                infoView(title: NSLocalizedString("Region of Origin",
                                                  comment: ""),
                         content: item?.itemCountry)
                if let companies = item?.itemCompanies, let company = item?.itemCompany {
                    if !companies.isEmpty {
                        NavigationLink(value: companies) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Production Companies")
                                            .font(.caption)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(company)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .accessibilityElement(children: .combine)
                                Spacer()
                            }
                            .padding([.horizontal, .top], 2)
                        }
#if os(macOS)
                        .buttonStyle(.link)
#endif
                    }
                } else {
                    infoView(title: NSLocalizedString("Production Company",
                                                      comment: ""),
                             content: item?.itemCompany)
                }
            }
        }
        .groupBoxStyle(TransparentGroupBox())
    }
    
    @ViewBuilder
    private func infoView(title: String, content: String?) -> some View {
        if let content, !content.isEmpty {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                    Text(content)
                        .multilineTextAlignment(.leading)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                Spacer()
            }
            .padding([.horizontal, .top], 2)
        } else {
            EmptyView()
        }
    }
}

extension ItemContentDetails {
    // MARK: Computed properties
#if !os(tvOS)
    private var cronicaUrl: URL? {
        guard let item = viewModel.content else { return nil }
        let encodedTitle = item.itemTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let posterPath = item.posterPath ?? String()
        let encodedPoster = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: "https://alexandremadeira.dev/cronica/details?id=\(item.itemContentID)&img=\(encodedPoster ?? String())&title=\(encodedTitle ?? String())")
    }
#endif
    
    // MARK: Action Buttons
    private var watchButton: some View {
        Button {
            viewModel.update(.watched)
            resetPopupAnimation()
            animatePopup(for: viewModel.isWatched ? .markedWatched : .removedWatched)
        } label: {
#if os(macOS)
            Label("Watched",
                  systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
            .symbolEffect(viewModel.isWatched ? .bounce.down : .bounce.up,
                          value: viewModel.isWatched)
#else
            VStack {
                if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
                    Image(systemName: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                        .symbolEffect(viewModel.isWatched ? .bounce.down : .bounce.up,
                                      value: viewModel.isWatched)
                } else {
                    Image(systemName: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                }
                Text("Watched")
                    .padding(.top, 2)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .frame(width: DrawingConstants.buttonWidth, height: DrawingConstants.buttonHeight)
#endif
        }
        .keyboardShortcut("w", modifiers: [.option])
        .controlSize(.small)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: DrawingConstants.buttonRadius))
        .tint(.primary)
#if os(iOS)
        .applyHoverEffect()
#endif
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
            resetPopupAnimation()
            animatePopup(for: viewModel.isFavorite ? .markedFavorite : .removedFavorite)
            withAnimation { showPopup = true }
        } label: {
            VStack {
                if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .symbolEffect(viewModel.isFavorite ? .bounce.down : .bounce.up,
                                      value: viewModel.isFavorite)
                } else {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                }
                Text("Favorite")
                    .padding(.top, 2)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .frame(width: DrawingConstants.buttonWidth, height: DrawingConstants.buttonHeight)
        }
        .keyboardShortcut("f", modifiers: [.option])
        .controlSize(.small)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: DrawingConstants.buttonRadius))
        .tint(.primary)
#if os(iOS)
        .applyHoverEffect()
#endif
    }
    
    private var listButton: some View {
        Button {
            showCustomList.toggle()
        } label: {
            VStack {
                Image(systemName: viewModel.isItemAddedToAnyList ? "rectangle.on.rectangle.angled.fill" : "rectangle.on.rectangle.angled")
                Text("Lists")
                    .padding(.top, 2)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .frame(width: DrawingConstants.buttonWidth, height: DrawingConstants.buttonHeight)
        }
        .controlSize(.small)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: DrawingConstants.buttonRadius))
        .tint(.primary)
#if os(iOS)
        .applyHoverEffect()
#endif
    }
    
#if !os(tvOS)
    // MARK: Toolbar
    @ViewBuilder
    private var watchButtonToolbar: some View {
        if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
            Button(viewModel.isWatched ? "Unwatched" : "Watched",
                   systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark") {
                viewModel.update(.watched)
                animatePopup(for: viewModel.isWatched ? .markedWatched : .removedWatched)
            }.symbolEffect(.bounce.down, value: viewModel.isWatched)
        } else {
            Button(viewModel.isWatched ? "Unwatched" : "Watched",
                   systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark") {
                viewModel.update(.watched)
                animatePopup(for: viewModel.isWatched ? .markedWatched : .removedWatched)
            }
        }
    }
    
    @ViewBuilder
    private var favoriteButtonToolbar: some View {
        if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
            Button(viewModel.isFavorite ? "Unfavorite" : "Favorite",
                   systemImage: viewModel.isFavorite ? "heart.fill" : "heart") {
                viewModel.update(.favorite)
                animatePopup(for: viewModel.isFavorite ? .markedFavorite : .removedFavorite)
            }.symbolEffect(.bounce.down, value: viewModel.isFavorite)
        } else {
            Button(viewModel.isFavorite ? "Unfavorite" : "Favorite",
                   systemImage: viewModel.isFavorite ? "heart.fill" : "heart") {
                viewModel.update(.favorite)
                animatePopup(for: viewModel.isFavorite ? .markedFavorite : .removedFavorite)
            }
        }
    }
    
    @ViewBuilder
    private var pinButtonToolbar: some View {
        if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
            Button(viewModel.isPin ? "Unpin" : "Pin",
                   systemImage: viewModel.isPin ? "pin.fill" : "pin") {
                viewModel.update(.pin)
                animatePopup(for: viewModel.isPin ? .markedPin : .removedPin)
            }.symbolEffect(.bounce.down, value: viewModel.isPin)
        } else {
            Button(viewModel.isPin ? "Unpin" : "Pin",
                   systemImage: viewModel.isPin ? "pin.fill" : "pin") {
                viewModel.update(.pin)
                animatePopup(for: viewModel.isPin ? .markedPin : .removedPin)
            }
        }
    }
    
    @ViewBuilder
    private var archiveButtonToolbar: some View {
        if #available(iOS 17, *), #available(tvOS 17, *), #available(macOS 14, *) {
            Button(viewModel.isArchive ? "Unarchive" : "Archive",
                   systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox") {
                viewModel.update(.archive)
                animatePopup(for: viewModel.isArchive ? .markedArchive : .removedArchive)
            }.symbolEffect(.bounce.down, value: viewModel.isArchive)
        } else {
            Button(viewModel.isArchive ? "Unarchive" : "Archive",
                   systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox") {
                viewModel.update(.archive)
                animatePopup(for: viewModel.isArchive ? .markedArchive : .removedArchive)
            }
        }
    }
    
    private var reviewButtonToolbar: some View {
        Button("Review", systemImage: "note.text") { showUserNotes.toggle() }
    }
    
    @ViewBuilder
    private var shareButton: some View {
        switch store.shareLinkPreference {
        case .tmdb: if let url = viewModel.content?.itemURL { ShareLink(item: url) }
        case .cronica: if let cronicaUrl {
            ShareLink(item: cronicaUrl, message: Text(title))
        }
        }
    }
    
    private var openInMenu: some View {
        Menu("Open in",
             systemImage: "ellipsis.circle") {
            
            if let homepage = viewModel.content?.homepage, let url = URL(string: homepage) {
                Button("Official Website") {
                    openUrl(for: url)
                }
            }
            if viewModel.content?.hasIMDbUrl ?? false {
                Button("IMDb") {
                    guard let url = viewModel.content?.imdbUrl else { return }
                    openUrl(for: url)
                }
            }
            Button("The Movie Database") {
                guard let url = viewModel.content?.itemURL else { return }
                openUrl(for: url)
            }
        }
    }
    
    private var toolbarRow: some View {
        HStack {
            shareButton
            if viewModel.isInWatchlist {
                if type == .movie {
                    favoriteButtonToolbar
                } else {
                    watchButtonToolbar
                }
                archiveButtonToolbar
                pinButtonToolbar
                reviewButtonToolbar
            }
            openInMenu
        }
        .disabled(viewModel.isLoading ? true : false)
    }
    
    private var moreMenu: some View {
        Menu("More Options", systemImage: "ellipsis.circle") {
            if UIDevice.isIPhone {
                if viewModel.isInWatchlist {
                    if type == .movie {
                        favoriteButtonToolbar
                    } else {
                        watchButtonToolbar
                    }
                    archiveButtonToolbar
                    pinButtonToolbar
                    reviewButtonToolbar
                }
            }
            openInMenu
        }
        .labelStyle(.iconOnly)
        .disabled(viewModel.isLoading ? true : false)
    }
#endif
    
    // MARK: Functions
    private func resetPopupAnimation() {
        if showPopup { showPopup = false }
        if popupType != nil { popupType = nil }
    }
    
    private func animatePopup(for action: ActionPopupItems) {
        resetPopupAnimation()
        popupType = action
        withAnimation {
            showPopup = true
        }
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = viewModel.isWatched ? "rectangle.badge.checkmark" : "rectangle.badge.checkmark.fill"
        case .favorite: animationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin"
        case .archive: animationImage = viewModel.isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation(.bouncy) { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.bouncy) { animateGesture = false }
        }
    }
    
#if !os(tvOS)
    private func openUrl(for url: URL) {
#if os(iOS)
        UIApplication.shared.open(url)
#else
        NSWorkspace.shared.open(url)
#endif
    }
#endif
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 12
#if os(iOS)
    static let posterWidth: CGFloat = UIDevice.isIPhone ? 200 : 280
    static let posterHeight: CGFloat = UIDevice.isIPhone ? 300 : 440
    static let coverWidth: CGFloat = 360
    static let coverHeight: CGFloat = 210
#elseif os(tvOS)
    static let posterWidth: CGFloat = 450
    static let posterHeight: CGFloat = 700
#elseif os(macOS)
    static let posterWidth: CGFloat = 280
    static let posterHeight: CGFloat = 440
#endif
    static let imageRadius: CGFloat = 12
    static let buttonWidth: CGFloat = 75
    static let buttonHeight: CGFloat = 50
    static let buttonRadius: CGFloat = 12
}

#Preview {
    NavigationStack {
        ItemContentDetails(title: ItemContent.example.itemTitle,
                           id: ItemContent.example.id,
                           type: .movie)
    }
}
