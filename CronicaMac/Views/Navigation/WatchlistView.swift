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
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
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
