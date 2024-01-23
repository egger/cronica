//
//  CustomWatchlist.swift
//  Cronica
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
    @AppStorage("customListShowAllItems") private var showAllItems = true
    @AppStorage("customListMediaTypeFilter") private var mediaTypeFilter: MediaTypeFilters = .showAll
    @AppStorage("customListSmartFilter") private var selectedOrder: SmartFiltersTypes = .released
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    @AppStorage("customListSortOrder") private var sortOrder: WatchlistSortOrder = .titleAsc
    private var sortedItems: [WatchlistItem] {
        guard let items = selectedList?.itemsArray else { return [] }
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
        case .showAll:
            return sortedItems
        case .movies:
            return sortedItems.filter { $0.isMovie }
        case .tvShows:
            return sortedItems.filter { $0.isTvShow }
        }
    }
    var body: some View {
        VStack {
            if let items = selectedList?.itemsArray {
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
                }
#endif
                if items.isEmpty {
                    EmptyListView()
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
                                                 title: selectedOrder.title,
                                                 showPopup: $showPopup, popupType: $popupType)
                            case .card:
                                WatchlistCardSection(items: smartFiltersItems,
                                                     title: selectedOrder.title,
                                                     showPopup: $showPopup,
                                                     popupType: $popupType)
                            case .poster:
                                WatchlistPosterSection(items: smartFiltersItems,
                                                       title: selectedOrder.title,
                                                       showPopup: $showPopup, popupType: $popupType)
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                styleButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                filterButton
            }
#elseif os(macOS)
            filterButton
#else
            filterButton
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
        #elseif os(macOS)
        .searchable(text: $query, placement: .toolbar, prompt: "Search \(selectedList?.itemTitle ?? "List")")
#endif
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
    }
    
    private var styleButton: some View {
        Menu {
            Picker(selection: $settings.watchlistStyle) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("Display Style", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("Display Style", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
    
    private var filterButton: some View {
        Menu {
#if !os(tvOS)
            Toggle("Show All", isOn: $showAllItems)
            Picker("Media Type", selection: $mediaTypeFilter) {
                ForEach(MediaTypeFilters.allCases) { sort in
                    Text(sort.localizableTitle).tag(sort)
                }
            }
#if os(macOS)
            .pickerStyle(.inline)
#else
            .pickerStyle(.menu)
#endif
            .disabled(!showAllItems)
            Divider()
#endif
            Picker("Smart Filters", selection: $selectedOrder) {
                ForEach(SmartFiltersTypes.allCases) { sort in
                    Text(sort.title).tag(sort)
                }
            }
            .disabled(showAllItems)
#if os(macOS)
            .pickerStyle(.inline)
#endif
            Picker("Sort Order",
                   selection: $sortOrder) {
                ForEach(WatchlistSortOrder.allCases) { item in
                    Text(item.localizableName).tag(item)
                }
            }
#if os(iOS) || os(tvOS)
                   .pickerStyle(.menu)
#else
                   .pickerStyle(.inline)
#endif
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .accessibilityLabel("Sort List")
        }
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    private var noResults: some View {
       SearchContentUnavailableView(query: query)
    }
}

struct EmptyListView: View {
    var body: some View {
        if #available(iOS 17, *) {
            ContentUnavailableView("Empty List", systemImage: "rectangle.on.rectangle")
                .padding()
        } else {
            Text("Empty List")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

struct SearchContentUnavailableView: View {
    let query: String
    var body: some View {
        if #available(iOS 17, *) {
            ContentUnavailableView.search(text: query)
        } else {
            VStack {
                Text("No result found for '\(query)'.")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
    }
}
