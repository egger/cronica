//
//  CustomWatchlist.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import SwiftUI

struct CustomWatchlist: View {
    @Binding var selectedList: CustomList?
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    @State private var scope: WatchlistSearchScope = .noScope
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    @State private var isSearching = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showFilter = false
    @State private var showAllItems = true
    @State private var mediaTypeFilter: MediaTypeFilters = .noFilter
    @State private var selectedOrder: DefaultListTypes = .released
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        VStack {
#if os(tvOS)
            frameStyle
#else
            switch settings.watchlistStyle {
            case .list: listStyle
            case .poster: posterStyle
            case .card: frameStyle
            }
#endif
        }
        .sheet(isPresented: $showFilter) {
            NavigationStack {
                WatchListFilter(selectedOrder: $selectedOrder, showAllItems: $showAllItems, mediaTypeFilter: $mediaTypeFilter, showView: $showFilter)
            }
            .presentationDetents([.large])
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                styleButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                filterPicker
            }
#else
            filterPicker
#endif
        }
#if os(iOS)
        .searchable(text: $query,
                    placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always),
                    prompt: "Search \(selectedList?.itemTitle ?? "List")")
        .searchScopes($scope) {
            ForEach(WatchlistSearchScope.allCases) { scope in
                Text(scope.localizableTitle).tag(scope)
            }
        }
        .disableAutocorrection(true)
        .task(id: query) {
            isSearching = true
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !filteredItems.isEmpty { filteredItems.removeAll() }
            if let items = selectedList?.itemsArray {
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
            }
            isSearching = false
        }
#endif
    }
    
#if os(iOS) || os(macOS)
    private var styleButton: some View {
        Menu {
            Picker(selection: $settings.watchlistStyle) {
                ForEach(WatchlistItemType.allCases) { item in
                    Text(item.localizableName).tag(item)
                }
            } label: {
                Label("watchlistDisplayTypePicker", systemImage: "rectangle.grid.2x2")
            }
        } label: {
            Label("watchlistDisplayTypePicker", systemImage: "rectangle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
#endif
    
    private var filterPicker: some View {
        Button {
            showFilter.toggle()
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
    
#if os(iOS) || os(macOS)
    @ViewBuilder
    private var listStyle: some View {
        if let items = selectedList?.itemsArray {
            if items.isEmpty {
                if scope != .noScope {
                    empty
                } else {
                    empty
                }
            } else {
                if !filteredItems.isEmpty {
                    switch scope {
                    case .noScope:
                        WatchListSection(items: filteredItems,
                                         title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    case .movies:
                        WatchListSection(items: filteredItems.filter { $0.isMovie },
                                         title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    case .shows:
                        WatchListSection(items: filteredItems.filter { $0.isTvShow },
                                         title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    }
                } else if !query.isEmpty && filteredItems.isEmpty && !isSearching  {
                    noResults
                } else {
                    if showAllItems {
                        switch mediaTypeFilter {
                        case .noFilter:
                            WatchListSection(items: items.filter { $0.title != nil }, title: "allItems",
                                             showPopup: $showPopup, popupType: $popupType)
                        case .movies:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie }, title: "allItemsMovies",
                                             showPopup: $showPopup, popupType: $popupType)
                        case .tvShows:
                            WatchListSection(items: items.filter { $0.itemMedia == .tvShow }, title: "allItemsTVShows",
                                             showPopup: $showPopup, popupType: $popupType)
                        }
                        
                    } else {
                        switch selectedOrder {
                        case .released:
                            WatchListSection(items: items.filter { $0.isReleased },
                                             title: DefaultListTypes.released.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .production:
                            WatchListSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                             title: DefaultListTypes.production.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .favorites:
                            WatchListSection(items: items.filter { $0.isFavorite },
                                             title: DefaultListTypes.favorites.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .watched:
                            WatchListSection(items: items.filter { $0.isWatched },
                                             title: DefaultListTypes.watched.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .pin:
                            WatchListSection(items: items.filter { $0.isPin },
                                             title: DefaultListTypes.pin.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .archive:
                            WatchListSection(items: items.filter { $0.isArchive },
                                             title: DefaultListTypes.archive.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .watching:
                            WatchListSection(items: items.filter { $0.isCurrentlyWatching },
                                             title: DefaultListTypes.watching.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        }
                    }
                }
            }
        }
    }
#endif
    
    @ViewBuilder
    private var frameStyle: some View {
        if let items = selectedList?.itemsArray {
            if !filteredItems.isEmpty {
                switch scope {
                case .noScope:
                    WatchlistCardSection(items: filteredItems,
                                         title: "Search results",
                                         showPopup: $showPopup,
                                         popupType: $popupType)
                case .movies:
                    WatchlistCardSection(items: filteredItems.filter { $0.isMovie },
                                         title: "Search results",
                                         showPopup: $showPopup,
                                         popupType: $popupType)
                case .shows:
                    WatchlistCardSection(items: filteredItems.filter { $0.isTvShow },
                                         title: "Search results",
                                         showPopup: $showPopup,
                                         popupType: $popupType)
                }
            } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
                noResults
            } else {
                if showAllItems {
                    switch mediaTypeFilter {
                    case .noFilter:
                        WatchlistCardSection(items: items.filter { $0.title != nil },
                                             title: "allItems",
                                             showPopup: $showPopup,
                                             popupType: $popupType)
                    case .movies:
                        WatchlistCardSection(items: items.filter { $0.isMovie },
                                             title: "allItemsMovies",
                                             showPopup: $showPopup,
                                             popupType: $popupType)
                    case .tvShows:
                        WatchlistCardSection(items: items.filter { $0.isTvShow },
                                             title: "allItemsTVShows",
                                             showPopup: $showPopup,
                                             popupType: $popupType)
                    }
                } else {
                    switch selectedOrder {
                    case .released:
                        WatchlistCardSection(items: items.filter { $0.isReleased },
                                             title: DefaultListTypes.released.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .production:
                        WatchlistCardSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                             title: DefaultListTypes.production.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .watched:
                        WatchlistCardSection(items: items.filter { $0.isWatched },
                                             title: DefaultListTypes.watched.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .favorites:
                        WatchlistCardSection(items: items.filter { $0.isFavorite },
                                             title: DefaultListTypes.favorites.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .pin:
                        WatchlistCardSection(items: items.filter { $0.isPin },
                                             title: DefaultListTypes.pin.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .archive:
                        WatchlistCardSection(items: items.filter { $0.isArchive },
                                             title: DefaultListTypes.archive.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    case .watching:
                        WatchlistCardSection(items: items.filter { $0.isCurrentlyWatching },
                                             title: DefaultListTypes.watching.title,
                                             showPopup: $showPopup, popupType: $popupType)
                    }
                }
            }
        }
        
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        if let items = selectedList?.itemsArray {
            if !filteredItems.isEmpty {
                switch scope {
                case .noScope:
                    WatchlistPosterSection(items: filteredItems,
                                           title: "Search results", showPopup: $showPopup, popupType: $popupType)
                case .movies:
                    WatchlistPosterSection(items: filteredItems.filter { $0.isMovie },
                                           title: "Search results", showPopup: $showPopup, popupType: $popupType)
                case .shows:
                    WatchlistPosterSection(items: filteredItems.filter { $0.isTvShow },
                                           title: "Search results", showPopup: $showPopup, popupType: $popupType)
                }
            } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
                noResults
            } else {
                if showAllItems {
                    switch mediaTypeFilter {
                    case .noFilter:
                        WatchlistPosterSection(items: items.filter { $0.title != nil },
                                               title: "allItems", showPopup: $showPopup, popupType: $popupType)
                    case .movies:
                        WatchlistPosterSection(items: items.filter { $0.isMovie },
                                               title: "allItemsMovies", showPopup: $showPopup, popupType: $popupType)
                    case .tvShows:
                        WatchlistPosterSection(items: items.filter { $0.isTvShow },
                                               title: "allItemsTVShows", showPopup: $showPopup, popupType: $popupType)
                    }
                } else {
                    switch selectedOrder {
                    case .released:
                        WatchlistPosterSection(items: items.filter { $0.isReleased },
                                               title: DefaultListTypes.released.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .production:
                        WatchlistPosterSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                               title: DefaultListTypes.production.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .watched:
                        WatchlistPosterSection(items: items.filter { $0.isWatched },
                                               title: DefaultListTypes.watched.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .favorites:
                        WatchlistPosterSection(items: items.filter { $0.isFavorite },
                                               title: DefaultListTypes.favorites.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .pin:
                        WatchlistPosterSection(items: items.filter { $0.isPin },
                                               title: DefaultListTypes.pin.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .archive:
                        WatchlistPosterSection(items: items.filter { $0.isArchive },
                                               title: DefaultListTypes.archive.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    case .watching:
                        WatchlistPosterSection(items: items.filter { $0.isCurrentlyWatching },
                                               title: DefaultListTypes.watching.title,
                                               showPopup: $showPopup, popupType: $popupType)
                    }
                }
            }
        }
        
    }
    
    private var noResults: some View {
        CenterHorizontalView {
            Text("No results")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private var empty: some View {
        Text("This list is empty.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
    }
}
