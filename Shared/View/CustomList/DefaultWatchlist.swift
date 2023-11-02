//
//  DefaultWatchlist.swift
//  Cronica
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
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Watchlist")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                                Text(smartFilter.title)
                                    .fontWeight(.semibold)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        sortButton
                        Menu {
                            Picker("Smart Filters", selection: $smartFilter) {
                                ForEach(SmartFiltersTypes.allCases) { sort in
                                    Text(sort.title).tag(sort)
                                }
                            }
                            .pickerStyle(.inline)
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
                    switch settings.watchlistStyle {
                    case .list:
                        WatchlistCardSection(items: smartFiltersItems,
                                             title: String(), showPopup: $showPopup, popupType: $popupType)
                    case .card:
                        WatchlistCardSection(items: smartFiltersItems,
                                             title: String(), showPopup: $showPopup, popupType: $popupType)
                    case .poster:
                        WatchlistPosterSection(items: smartFiltersItems,
                                               title: String(), showPopup: $showPopup, popupType: $popupType)
                    }
                    
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
            filterButton
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
#elseif os(macOS)
        .searchable(text: $query, placement: .toolbar)
#endif
        .disableAutocorrection(true)
        .task(id: query) {
            await search()
        }
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
        Menu {
            Toggle("defaultWatchlistShowAllItems", isOn: $showAllItems)
            Picker("mediaTypeFilter", selection: $mediaTypeFilter) {
                ForEach(MediaTypeFilters.allCases) { sort in
                    Text(sort.localizableTitle).tag(sort)
                }
            }
            .pickerStyle(.menu)
            .disabled(!showAllItems)
            Divider()
            Picker("Smart Filters", selection: $smartFilter) {
                ForEach(SmartFiltersTypes.allCases) { sort in
                    Text(sort.title).tag(sort)
                }
            }
            .disabled(showAllItems)
            #if os(macOS)
            .pickerStyle(.inline)
            #endif
#if os(macOS)
            sortButton
                .pickerStyle(.menu)
#endif
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .accessibilityLabel("Sort List")
        }
        .buttonStyle(.bordered)
    }
    
    private var sortButton: some View {
        Picker("Sort Order",
               systemImage: "arrow.up.arrow.down.circle",
               selection: $sortOrder) {
            ForEach(WatchlistSortOrder.allCases) { item in
                Text(item.localizableName).tag(item)
            }
        }
        #if os(iOS)
               .pickerStyle(.menu)
               .labelStyle(.iconOnly)
        #else
               .pickerStyle(.inline)
               .labelStyle(.titleOnly)
        #endif
    }
    
    private var styleButton: some View {
#if os(macOS)
        Picker(selection: $settings.watchlistStyle) {
            ForEach(SectionDetailsPreferredStyle.allCases) { item in
                Text(item.title).tag(item)
            }
        } label: {
            Label("watchlistDisplayTypePicker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
#else
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
#endif
    }
    
    private var empty: some View {
        ContentUnavailableView("Your list is empty.", systemImage: "rectangle.on.rectangle")
            .padding()
    }
    
    private var noResults: some View {
        ContentUnavailableView.search(text: query)
    }
}

#Preview {
    DefaultWatchlist(showPopup: .constant(false), popupType: .constant(nil))
}
