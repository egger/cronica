//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//
import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredMovieItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @State var selectedOrder: WatchListSortOrder = .optimized
    @State private var selectedItems = Set<WatchlistItem.ID>()
    @Environment(\.editMode) private var editMode
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
                        if !filteredMovieItems.isEmpty {
                            WatchListSection(items: filteredMovieItems,
                                             title: "Filtered Items")
                        } else if !query.isEmpty && filteredMovieItems.isEmpty {
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
                                WatchListSection(items: items.filter { $0.isReleasedMovie },
                                                 title: "Released Movies")
                                WatchListSection(items: items.filter { $0.isReleasedTvShow },
                                                 title: "Released Shows")
                                WatchListSection(items: items.filter { $0.isUpcomingMovie },
                                                 title: "Upcoming Movies")
                                WatchListSection(items: items.filter { $0.isUpcomingTvShow },
                                                 title: "Upcoming Seasons")
                                WatchListSection(items: items.filter { $0.isInProduction },
                                                 title: "In Production")
                            case .people:
                                PersonStruct()
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
                    HStack {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker(selection: $selectedOrder, content: {
                        ForEach(WatchListSortOrder.allCases) { sort in
                            Label(sort.title, systemImage: "arrow.up.arrow.down.circle.fill").tag(sort)
                                .labelStyle(.iconOnly)
                            //Text(sort.title).tag(sort)
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
