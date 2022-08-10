//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//
import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @State private var query = ""
    @State private var selectedOrder: WatchListSortOrder = .optimized
    var body: some View {
        AdaptableNavigationView {
            VStack {
                if items.isEmpty {
                    Text("Your list is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        if !filteredItems.isEmpty {
                            WatchListSection(items: filteredItems,
                                             title: "Filtered Items")
                        } else if !query.isEmpty && filteredItems.isEmpty {
                            Text("No results found.")
                        } else {
                            switch selectedOrder {
                            case .type:
                                WatchListSection(items: items.filter { $0.isMovie },
                                                 title: "Movies")
                                WatchListSection(items: items.filter { $0.isTvShow },
                                                 title: "TV Shows")
                            case .status:
                                WatchListSection(items: items.filter { !$0.isWatched },
                                                 title: "To Watch")
                                WatchListSection(items: items.filter { $0.isWatched },
                                                 title: "Watched")
                            case .favorites:
                                WatchListSection(items: items.filter { $0.isFavorite },
                                                 title: "Favorites")
                            case .optimized:
                                WatchListSection(items: items.filter { $0.isReleasedMovie || $0.isReleasedTvShow },
                                                 title: "Released")
                                WatchListSection(items: items.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow },
                                                 title: "Upcoming")
                                WatchListSection(items: items.filter { $0.isInProduction },
                                                 title: "In Production")
                            }
                        }
                    }
                    .listStyle(.inset)
                    .dropDestination(for: ItemContent.self) { items, location  in
                        let context = PersistenceController.shared
                        for item in items {
                            context.save(item)
                        }
                        return true
                    } isTargeted: { inDropArea in
                        print(inDropArea)
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .navigationDestination(for: PersonItem.self) { item in
                PersonDetailsView(title: item.personName, id: Int(item.id))
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .refreshable {
                Task {
                    await refresh()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker(selection: $selectedOrder, content: {
                        ForEach(WatchListSortOrder.allCases) { sort in
                            Label(sort.title, systemImage: "arrow.up.arrow.down.circle").tag(sort)
                                .labelStyle(.iconOnly)
                        }
                    }, label: {
                        Label("Sort List", systemImage: "arrow.up.arrow.down.circle")
                    })
                }
            }
            .searchable(text: $query,
                        placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always),
                        prompt: "Search watchlist")
            .disableAutocorrection(true)
        }
    }
    
    private func refresh() async {
        HapticManager.shared.softHaptic()
        DispatchQueue.global(qos: .background).async {
            let background = BackgroundManager()
            background.handleAppRefreshContent()
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
