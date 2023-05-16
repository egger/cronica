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
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    @State private var isSearching = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showFilter = false
    @AppStorage("watchlistShowAllItems") private var showAllItems = false
    @AppStorage("watchlistMediaTypeFilter") private var mediaTypeFilter: MediaTypeFilters = .noFilter
    var body: some View {
        VStack {
#if os(tvOS)
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
            .padding(.horizontal)
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
                WatchListFilter(selectedOrder: $selectedOrder,
                                showAllItems: $showAllItems,
                                mediaTypeFilter: $mediaTypeFilter,
                                showView: $showFilter)
            }
            .presentationDetents([.medium, .large])
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
                HStack {
                    filterButton
                    styleButton
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
            do {
                isSearching = true
                try await Task.sleep(nanoseconds: 300_000_000)
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                isSearching = false
            } catch {
                if Task.isCancelled { return }
            }
        }
#endif
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
                    case .upcoming:
                        WatchListSection(items: items.filter { $0.isUpcoming },
                                         title: DefaultListTypes.upcoming.title)
                    case .production:
                        WatchListSection(items: items.filter { $0.isInProduction },
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
                    }
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
                case .upcoming:
                    WatchlistCardSection(items: items.filter { $0.isUpcoming },
                                         title: DefaultListTypes.upcoming.title)
                case .production:
                    WatchlistCardSection(items: items.filter { $0.isInProduction },
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
                }
            }
        }
    }
    
    @ViewBuilder
    private var posterStyle: some View {
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
                case .upcoming:
                    WatchlistPosterSection(items: items.filter { $0.isUpcoming },
                                           title: DefaultListTypes.upcoming.title)
                case .production:
                    WatchlistPosterSection(items: items.filter { $0.isInProduction },
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
                }
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
        DefaultWatchlist()
    }
}
