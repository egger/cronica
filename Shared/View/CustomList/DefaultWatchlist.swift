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
    @AppStorage("selectedOrder") private var smartFilter: SmartFiltersTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var isSearching = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showFilter = false
    @AppStorage("watchlistShowAllItems") private var showAllItems = false
    @AppStorage("watchlistMediaTypeFilter") private var mediaTypeFilter: MediaTypeFilters = .noFilter
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    @AppStorage("defaultWatchlistSortOrder") private var sortOrder: WatchlistSortOrder = .titleAsc
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
        switch smartFilter {
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
            return sortedItems.filter { $0.isPin }
        case .archive:
            return sortedItems.filter { $0.isArchive }
        case .notWatched:
            return sortedItems.filter { !$0.isCurrentlyWatching && !$0.isWatched && $0.isReleased }
        }
    }
    private var scopeFiltersItems: [WatchlistItem] {
        switch scope {
        case .noScope:
            return filteredItems
        case .movies:
            return filteredItems.filter { $0.isMovie }
        case .shows:
            return filteredItems.filter { $0.isTvShow }
        }
    }
    private var mediaTypeItems: [WatchlistItem] {
        switch mediaTypeFilter {
        case .noFilter:
            return sortedItems
        case .movies:
            return sortedItems.filter { $0.isMovie }
        case .tvShows:
            return sortedItems.filter { $0.isTvShow }
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
                                Text(smartFilter.title)
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
				if smartFiltersItems.isEmpty {
					empty
				} else {
					WatchlistCardSection(items: smartFiltersItems,
										 title: "Search results", showPopup: $showPopup, popupType: $popupType)
				}
            }
#else
            if items.isEmpty {
                if scope != .noScope {
                    empty
                } else {
                    empty
                }
            } else {
                if !filteredItems.isEmpty {
                    switch settings.watchlistStyle {
                    case .list:
                        WatchListSection(items: scopeFiltersItems,
                                         title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    case .card:
                        WatchlistCardSection(items: scopeFiltersItems,
                                             title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    case .poster:
                        WatchlistPosterSection(items: scopeFiltersItems,
                                               title: "Search results", showPopup: $showPopup, popupType: $popupType)
                    }
                    
                } else if !query.isEmpty && filteredItems.isEmpty && !isSearching  {
                    noResults
                } else {
                    if showAllItems {
                        switch settings.watchlistStyle {
                        case .list:
                            WatchListSection(items: mediaTypeItems,
                                             title: mediaTypeFilter.localizableTitle,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .card:
                            WatchlistCardSection(items: mediaTypeItems,
                                                 title: mediaTypeFilter.localizableTitle, showPopup: $showPopup, popupType: $popupType)
                        case .poster:
                            WatchlistPosterSection(items: mediaTypeItems,
                                                   title: mediaTypeFilter.localizableTitle, showPopup: $showPopup, popupType: $popupType)
                        }
                    } else {
                        switch settings.watchlistStyle {
                        case .list:
                            WatchListSection(items: smartFiltersItems,
                                             title: smartFilter.title,
                                             showPopup: $showPopup, popupType: $popupType)
                        case .card:
                            WatchlistCardSection(items: smartFiltersItems,
                                                 title: smartFilter.title,
                                                 showPopup: $showPopup,
                                                 popupType: $popupType)
                        case .poster:
                            WatchlistPosterSection(items: smartFiltersItems,
                                                   title: smartFilter.title,
                                                   showPopup: $showPopup, popupType: $popupType)
                        }
                    }
                }
            }
			#endif
        }
        .sheet(isPresented: $showFilter) {
            NavigationStack {
                WatchListFilter(selectedOrder: $smartFilter,
                                showAllItems: $showAllItems,
                                mediaTypeFilter: $mediaTypeFilter,
                                showView: $showFilter)
            }
            .presentationDetents([.large])
#if os(iOS)
            .appTheme()
            .appTint()
#elseif os(macOS)
            .frame(width: 380, height: 420, alignment: .center)
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
        .onChange(of: smartFilter) { _ in
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
#if os(tvOS)
        EmptyView()
#else
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
#endif
    }
    
#if os(iOS) || os(macOS)
    private var styleButton: some View {
        Menu {
            Picker(selection: $settings.watchlistStyle) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("watchlistDisplayTypePicker", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("watchlistDisplayTypePicker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
#endif
    
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
