//
//  WatchlistView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var isSearching = false
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    var body: some View {
        NavigationStack {
            VStack {
                posterStyle
            }
            .navigationTitle("Watchlist")
            .searchable(text: $query, prompt: "Search watchlist")
            .autocorrectionDisabled()
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
            }
            .toolbar {
                ToolbarItem {
                    Picker(selection: $selectedOrder, content: {
                        ForEach(DefaultListTypes.allCases) { sort in
                            Text(sort.title).tag(sort)
                        }
                    }, label: {
                        Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                    })
                }
            }
            .dropDestination(for: ItemContent.self) { items, _  in
                fetchDroppedItems(for: items)
                return true
            }
            .task(id: query) {
                do {
                    isSearching = true
                    try await Task.sleep(nanoseconds: 300_000_000)
                    if !filteredItems.isEmpty { filteredItems.removeAll() }
                    withAnimation {
                        filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                    }
                    isSearching = false
                } catch {
                    if Task.isCancelled { return }
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                                    for: "WatchlistView.task(id: query)")
                }
            }
        }
    }
    
    @ViewBuilder
    private var frameStyle: some View {
        EmptyView()
//        if !filteredItems.isEmpty {
//            WatchlistPosterSection(items: filteredItems)
//        } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
//            noResults
//        } else {
//            switch selectedOrder {
//            case .released:
//                WatchlistPosterSection(items: items.filter { $0.isReleased })
//            case .upcoming:
//                WatchlistPosterSection(items: items.filter { $0.isUpcoming })
//            case .production:
//                WatchlistPosterSection(items: items.filter { $0.isInProduction })
//            case .watched:
//                WatchlistPosterSection(items: items.filter { $0.isWatched })
//            case .favorites:
//                WatchlistPosterSection(items: items.filter { $0.isFavorite })
//            case .pin:
//                WatchlistPosterSection(items: items.filter { $0.isPin })
//            case .archive:
//                WatchlistPosterSection(items: items.filter { $0.isArchive })
//            }
//        }
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        if !filteredItems.isEmpty {
            WatchlistPosterSection(items: filteredItems, title: "Search results")
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
    
    private var noResults: some View {
        CenterHorizontalView {
            Text("No results")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func fetchDroppedItems(for items: [ItemContent]) {
        Task {
            for item in items {
                let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                guard let content else { return }
                PersistenceController.shared.save(content)
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
