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
    @AppStorage("filterTypeCustomList") private var filterType: CustomWatchListFilters = .all
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
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                filterPicker
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                syncButton
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
            do {
                isSearching = true
                try await Task.sleep(nanoseconds: 300_000_000)
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                if let items = selectedList?.itemsArray {
                    filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                }
                isSearching = false
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "WatchlistView.task(id: query)")
            }
        }
#endif
    }
    
    @ViewBuilder
    private var syncButton: some View {
        if let selectedList {
            if selectedList.isSyncEnabledTMDB {
                Section {
                    Button {
                        
                    } label: {
                        Label("syncNowTMDB", systemImage: "arrow.clockwise.circle.fill")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
    }
    
    private var filterPicker: some View {
#if os(iOS)
        Menu {
            Picker(selection: $filterType, content: {
                ForEach(CustomWatchListFilters.allCases) { sort in
                    Text(sort.localizableTitle).tag(sort)
                }
            }, label: {
                EmptyView()
            })
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
        }
#else
        Picker(selection: $filterType, content: {
            ForEach(CustomWatchListFilters.allCases) { sort in
                Text(sort.localizableTitle).tag(sort)
            }
        }, label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
        })
#endif
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
                    switch filterType {
                    case .all:
                        WatchListSection(items: items,
                                         title: selectedList?.itemCount ?? "",
                                         showDefaultFooter: false,
                                         alternativeFooter: selectedList?.itemFooter)
                    case .movies:
                        WatchListSection(items: items.filter { $0.isMovie },
                                         title: "Movies",
                                         alternativeFooter: selectedList?.itemFooter)
                    case .shows:
                        WatchListSection(items: items.filter { $0.isTvShow },
                                         title: "TV Shows",
                                         alternativeFooter: selectedList?.itemFooter)
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
                switch filterType {
                case .all:
                    WatchlistCardSection(items: items,
                                         title: selectedList?.itemCount ?? "")
                case .movies:
                    WatchlistCardSection(items: items.filter { $0.isMovie },
                                         title: "Movies")
                case .shows:
                    WatchlistCardSection(items: items.filter { $0.isTvShow },
                                         title: "TV Shows")
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
                switch filterType {
                case .all:
                    WatchlistPosterSection(items: items,
                                           title: selectedList?.itemCount ?? "")
                case .movies:
                    WatchlistPosterSection(items: items.filter { $0.isMovie },
                                           title: "Movies")
                case .shows:
                    WatchlistPosterSection(items: items.filter { $0.isTvShow },
                                           title: "TV Shows")
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
