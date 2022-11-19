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
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var isSearching = false
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
//                    if filteredItems.isEmpty {
//                        switch scope {
//                        case .noScope:
//                            WatchlistSection(items: filteredItems)
//                        case .movies:
//                            WatchlistSection(items: filteredItems.filter { $0.isMovie })
//                        case .shows:
//                            WatchlistSection(items: filteredItems.filter { $0.isTvShow })
//                        }
//                    } else if !query.isEmpty && filteredItems.isEmpty && !isSearching {
//                        Text("No results")
//                    }
                    switch selectedOrder {
                    case .released:
                        WatchlistSection(items: items.filter { $0.isReleased })
                    case .upcoming:
                        WatchlistSection(items: items.filter { $0.isUpcoming })
                    case .production:
                        WatchlistSection(items: items.filter { $0.isInProduction })
                    case .watched:
                        WatchlistSection(items: items.filter { $0.isWatched })
                    case .favorites:
                        WatchlistSection(items: items.filter { $0.isFavorite })
                    case .pin:
                        WatchlistSection(items: items.filter { $0.isPin })
                    }
                }
            }
            .navigationTitle("Watchlist")
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
                for item in items {
                    Task {
                        let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                        guard let content else { return }
                        PersistenceController.shared.save(content)
                    }
                }
                return true
            }
//            .searchable(text: $query)
//            .searchScopes($scope) {
//                ForEach(WatchlistSearchScope.allCases) { scope in
//                    Text(scope.localizableTitle).tag(scope)
//                }
//            }
//            .disableAutocorrection(true)
//            .task(id: query) {
//                do {
//                    isSearching = true
//                    try await Task.sleep(nanoseconds: 300_000_000)
//                    if !filteredItems.isEmpty { filteredItems.removeAll() }
//                    filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
//                    isSearching = false
//                } catch {
//                    if Task.isCancelled { return }
//                    CronicaTelemetry.shared.handleMessage(error.localizedDescription,
//                                                                    for: "WatchlistView.task(id: query)")
//                }
//            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

private struct WatchlistSection: View {
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160))
    ]
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { item in
                        WatchlistPoster(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        } else {
            VStack {
                Spacer()
                CenterHorizontalView {
                    Text("This list is empty.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
        }
    }
}
