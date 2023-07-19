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
            .presentationDetents([.medium, .large])
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
                                         title: "Search results")
                    case .movies:
                        WatchListSection(items: filteredItems.filter { $0.isMovie },
                                         title: "Search results")
                    case .shows:
                        WatchListSection(items: filteredItems.filter { $0.isTvShow },
                                         title: "Search results")
                    }
                } else if !query.isEmpty && filteredItems.isEmpty && !isSearching  {
                    noResults
                } else {
                    if showAllItems {
                        switch mediaTypeFilter {
                        case .noFilter:
                            WatchListSection(items: items.filter { $0.title != nil }, title: "allItems")
                        case .movies:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie }, title: "allItemsMovies")
                        case .tvShows:
                            WatchListSection(items: items.filter { $0.itemMedia == .tvShow }, title: "allItemsTVShows")
                        }
                        
                    } else {
                        switch selectedOrder {
                        case .released:
                            WatchListSection(items: items.filter { $0.isReleased },
                                             title: DefaultListTypes.released.title)
                        case .production:
                            WatchListSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                             title: DefaultListTypes.production.title)
                        case .favorites:
                            WatchListSection(items: items.filter { $0.isFavorite },
                                             title: DefaultListTypes.favorites.title)
                        case .watched:
                            WatchListSection(items: items.filter { $0.isWatched },
                                             title: DefaultListTypes.watched.title)
                        case .pin:
                            WatchListSection(items: items.filter { $0.isPin },
                                             title: DefaultListTypes.pin.title)
                        case .archive:
                            WatchListSection(items: items.filter { $0.isArchive },
                                             title: DefaultListTypes.archive.title)
                        case .watching:
                            WatchListSection(items: items.filter { $0.isCurrentlyWatching },
                                             title: DefaultListTypes.watching.title)
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
                                         title: "Search results")
                case .movies:
                    WatchlistCardSection(items: filteredItems.filter { $0.isMovie },
                                         title: "Search results")
                case .shows:
                    WatchlistCardSection(items: filteredItems.filter { $0.isTvShow },
                                         title: "Search results")
                }
            } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
                noResults
            } else {
                if showAllItems {
                    switch mediaTypeFilter {
                    case .noFilter:
                        WatchlistCardSection(items: items.filter { $0.title != nil },
                                             title: "allItems")
                    case .movies:
                        WatchlistCardSection(items: items.filter { $0.isMovie },
                                             title: "allItemsMovies")
                    case .tvShows:
                        WatchlistCardSection(items: items.filter { $0.isTvShow },
                                             title: "allItemsTVShows")
                    }
                } else {
                    switch selectedOrder {
                    case .released:
                        WatchlistCardSection(items: items.filter { $0.isReleased },
                                             title: DefaultListTypes.released.title)
                    case .production:
                        WatchlistCardSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                             title: DefaultListTypes.production.title)
                    case .watched:
                        WatchlistCardSection(items: items.filter { $0.isWatched },
                                             title: DefaultListTypes.watched.title)
                    case .favorites:
                        WatchlistCardSection(items: items.filter { $0.isFavorite },
                                             title: DefaultListTypes.favorites.title)
                    case .pin:
                        WatchlistCardSection(items: items.filter { $0.isPin },
                                             title: DefaultListTypes.pin.title)
                    case .archive:
                        WatchlistCardSection(items: items.filter { $0.isArchive },
                                             title: DefaultListTypes.archive.title)
                    case .watching:
                        WatchlistCardSection(items: items.filter { $0.isCurrentlyWatching },
                                             title: DefaultListTypes.watching.title)
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
                                           title: "Search results")
                case .movies:
                    WatchlistPosterSection(items: filteredItems.filter { $0.isMovie },
                                           title: "Search results")
                case .shows:
                    WatchlistPosterSection(items: filteredItems.filter { $0.isTvShow },
                                           title: "Search results")
                }
            } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
                noResults
            } else {
                if showAllItems {
                    switch mediaTypeFilter {
                    case .noFilter:
                        WatchlistPosterSection(items: items.filter { $0.title != nil },
                                               title: "allItems")
                    case .movies:
                        WatchlistPosterSection(items: items.filter { $0.isMovie },
                                               title: "allItemsMovies")
                    case .tvShows:
                        WatchlistPosterSection(items: items.filter { $0.isTvShow },
                                               title: "allItemsTVShows")
                    }
                } else {
                    switch selectedOrder {
                    case .released:
                        WatchlistPosterSection(items: items.filter { $0.isReleased },
                                               title: DefaultListTypes.released.title)
                    case .production:
                        WatchlistPosterSection(items: items.filter { $0.isInProduction || $0.isUpcoming },
                                               title: DefaultListTypes.production.title)
                    case .watched:
                        WatchlistPosterSection(items: items.filter { $0.isWatched },
                                               title: DefaultListTypes.watched.title)
                    case .favorites:
                        WatchlistPosterSection(items: items.filter { $0.isFavorite },
                                               title: DefaultListTypes.favorites.title)
                    case .pin:
                        WatchlistPosterSection(items: items.filter { $0.isPin },
                                               title: DefaultListTypes.pin.title)
                    case .archive:
                        WatchlistPosterSection(items: items.filter { $0.isArchive },
                                               title: DefaultListTypes.archive.title)
                    case .watching:
                        WatchlistPosterSection(items: items.filter { $0.isCurrentlyWatching },
                                               title: DefaultListTypes.watching.title)
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
