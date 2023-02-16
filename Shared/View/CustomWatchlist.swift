//
//  CustomWatchlist.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import SwiftUI

struct CustomWatchlist: View {
    @Binding var selectedList: CustomList?
    @State private var items = [WatchlistItem]()
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
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
        .onChange(of: selectedList, perform: { list in
            if let list {
                if !items.isEmpty {
                    items = []
                }
                items.append(contentsOf: list.listItems.sorted { $0.itemTitle < $1.itemTitle })
            }
        })
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
                WatchListSection(items: items,
                                 title: selectedList?.itemListHeader ?? "", showDefaultFooter: false)
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
            WatchlistCardSection(items: items,
                                 title: selectedList?.itemListHeader ?? "")
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
            WatchlistPosterSection(items: items,
                                   title: selectedList?.itemListHeader ?? "")
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
        Text("Your list is empty.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
    }
}

//struct CustomWatchlist_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomWatchlist()
//    }
//}
