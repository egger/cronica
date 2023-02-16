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
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    @State private var isSearching = false
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        VStack {
            switch settings.watchlistStyle {
            case .list: listStyle
            case .poster: posterStyle
            case .card: frameStyle
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                filterMenu
            }
#else
            filterMenu
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
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "WatchlistView.task(id: query)")
            }
        }
#endif
    }
    
    private var filterMenu: some View {
        Menu {
            Picker(selection: $selectedOrder, content: {
                ForEach(DefaultListTypes.allCases) { sort in
                    Text(sort.title).tag(sort)
                }
            }, label: {
                EmptyView()
            })
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
        }
    }
    
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