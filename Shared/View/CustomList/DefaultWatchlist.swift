//
//  DefaultWatchlist.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import SwiftUI

struct DefaultWatchlist: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var isSearching = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showFilter = false
    @AppStorage("watchlistShowAllItems") private var showAllItems = false
    @AppStorage("watchlistMediaTypeFilter") private var mediaTypeFilter: MediaTypeFilters = .noFilter
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    
    @State private var sortOrder: WatchlistSortOrder = .titleAsc
    private var sortedItems: [WatchlistItem] {
        switch sortOrder {
        case .titleAsc:
            return items.sorted { $0.itemTitle < $1.itemTitle }
        case .titleDesc:
            return items.sorted { $0.itemTitle > $1.itemTitle }
        case .ratingAsc:
            return items.sorted { $0.userRating < $1.userRating }
        case .ratingDesc:
            return items.sorted { $0.userRating > $1.userRating }
        case .dateAsc:
            return items.sorted { $0.itemSortDate < $1.itemSortDate }
        case .dateDesc:
            return items.sorted { $0.itemSortDate > $1.itemSortDate }
        }
    }
    private var smartFiltersItems: [WatchlistItem] {
        switch selectedOrder {
        case .released:
            return sortedItems.filter { $0.isReleased }
        case .production:
            return sortedItems.filter { $0.isInProduction || $0.isUpcoming }
        case .watching:
            return sortedItems.filter { $0.isCurrentlyWatching }
        case .watched:
            return sortedItems.filter { $0.isWatched }
        case .favorites:
            return sortedItems.filter { $0.isFavorite }
        case .pin:
            return sortedItems.filter { $0.isReleased }
        case .archive:
            return sortedItems.filter { $0.isArchive }
        }
    }
    var body: some View {
        VStack {
#if os(tvOS)
            ScrollView {
                if !items.isEmpty {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Watchlist")
                                .font(.title3)
                            if showAllItems {
                                Text(mediaTypeFilter.localizableTitle)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(selectedOrder.title)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        Spacer()
                        Button {
                            showFilter.toggle()
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .padding(.horizontal, 64)
                }
                frameStyle
            }
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
                WatchListFilter(selectedOrder: $selectedOrder,
                                showAllItems: $showAllItems,
                                mediaTypeFilter: $mediaTypeFilter,
                                showView: $showFilter)
            }
            .presentationDetents([.large])
#if os(iOS)
            .appTheme()
            .appTint()
#elseif os(macOS)
            .frame(width: 380, height: 220, alignment: .center)
#endif
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                styleButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    filterButton
                    sortButton
                }
            }
#elseif os(macOS)
            HStack {
                filterButton
                styleButton
            }
#endif
        }
#if os(iOS)
        .searchable(text: $query,
                    placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always),
                    prompt: "Search watchlist")
        .searchScopes($scope) {
            ForEach(WatchlistSearchScope.allCases) { scope in
                Text(scope.localizableTitle).tag(scope)
            }
        }
        .onChange(of: selectedOrder) { _ in
            withAnimation { showFilter.toggle() }
        }
        .disableAutocorrection(true)
        .task(id: query) {
            await search()
        }
#endif
    }
    
    private func search() async {
        do {
            isSearching = true
            try await Task.sleep(nanoseconds: 300_000_000)
            if !filteredItems.isEmpty { filteredItems.removeAll() }
            filteredItems.append(contentsOf: items.filter {
                ($0.itemTitle.localizedStandardContains(query)) as Bool
                || ($0.itemOriginalTitle.localizedStandardContains(query)) as Bool
            })
            isSearching = false
        } catch {
            if Task.isCancelled { return }
        }
    }
    
    private var filterButton: some View {
        Button {
            showFilter.toggle()
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
                .foregroundColor(showFilter ? .secondary : nil)
        }
#if os(tvOS)
        .buttonStyle(.bordered)
#endif
    }
    
    private var sortButton: some View {
        Menu {
            Picker(selection: $sortOrder) {
                ForEach(WatchlistSortOrder.allCases) { item in
                    Text(item.localizableName).tag(item)
                }
            } label: {
                Label("watchlistSortORder", systemImage: "arrow.up.arrow.down.circle")
            }
        } label: {
            Label("watchlistSortORder", systemImage: "arrow.up.arrow.down.circle")
                .labelStyle(.iconOnly)
        }
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
    
#if os(iOS) || os(macOS)
    @ViewBuilder
    private var listStyle: some View {
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
                        WatchListSection(items: sortedItems.filter { $0.title != nil },
                                         title: "allItems", showPopup: $showPopup, popupType: $popupType)
                    case .movies:
                        WatchListSection(items: sortedItems.filter { $0.itemMedia == .movie },
                                         title: "allItemsMovies", showPopup: $showPopup, popupType: $popupType)
                    case .tvShows:
                        WatchListSection(items: sortedItems.filter { $0.itemMedia == .tvShow },
                                         title: "allItemsTVShows", showPopup: $showPopup, popupType: $popupType)
                    }
                    
                } else {
                    WatchListSection(items: smartFiltersItems,
                                     title: selectedOrder.title,
                                     showPopup: $showPopup, popupType: $popupType)
                }
            }
        }
    }
#endif
    
    @ViewBuilder
    private var frameStyle: some View {
        if !filteredItems.isEmpty {
            switch scope {
            case .noScope:
                WatchlistCardSection(items: filteredItems,
                                     title: "Search results", showPopup: $showPopup, popupType: $popupType)
            case .movies:
                WatchlistCardSection(items: filteredItems.filter { $0.isMovie },
                                     title: "Search results", showPopup: $showPopup, popupType: $popupType)
            case .shows:
                WatchlistCardSection(items: filteredItems.filter { $0.isTvShow },
                                     title: "Search results", showPopup: $showPopup, popupType: $popupType)
            }
        } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
            noResults
        } else {
            if showAllItems {
                switch mediaTypeFilter {
                case .noFilter:
                    WatchlistCardSection(items: sortedItems.filter { $0.title != nil },
                                         title: "allItems", showPopup: $showPopup, popupType: $popupType)
                case .movies:
                    WatchlistCardSection(items: sortedItems.filter { $0.isMovie },
                                         title: "allItemsMovies", showPopup: $showPopup, popupType: $popupType)
                case .tvShows:
                    WatchlistCardSection(items: sortedItems.filter { $0.isTvShow },
                                         title: "allItemsTVShows", showPopup: $showPopup, popupType: $popupType)
                }
            } else {
                WatchlistCardSection(items: smartFiltersItems,
                                     title: selectedOrder.title,
                                     showPopup: $showPopup,
                                     popupType: $popupType)
            }
        }
    }
    
    @ViewBuilder
    private var posterStyle: some View {
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
                    WatchlistPosterSection(items: sortedItems.filter { $0.title != nil },
                                           title: "allItems", showPopup: $showPopup, popupType: $popupType)
                case .movies:
                    WatchlistPosterSection(items: sortedItems.filter { $0.isMovie },
                                           title: "allItemsMovies", showPopup: $showPopup, popupType: $popupType)
                case .tvShows:
                    WatchlistPosterSection(items: sortedItems.filter { $0.isTvShow },
                                           title: "allItemsTVShows", showPopup: $showPopup, popupType: $popupType)
                }
            } else {
                WatchlistPosterSection(items: smartFiltersItems,
                                       title: selectedOrder.title,
                                       showPopup: $showPopup, popupType: $popupType)
            }
        }
    }
    
    private var empty: some View {
        Text("Your list is empty.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
    }
    
    private var noResults: some View {
        CenterHorizontalView {
            Text("No results")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct DefaultWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        DefaultWatchlist(showPopup: .constant(false), popupType: .constant(nil))
    }
}
