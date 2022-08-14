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
    @State private var selectedOrder: DefaultListTypes = .released
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
                                             title: "Search results")
                        } else if !query.isEmpty && filteredItems.isEmpty {
                            Text("No results")
                        } else {
                            switch selectedOrder {
                            case .released:
                                WatchListSection(items: items.filter { $0.isReleasedMovie || $0.isReleasedTvShow },
                                                 title: "Released")
                            case .upcoming:
                                WatchListSection(items: items.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow },
                                                 title: "Upcoming")
                            case .production:
                                WatchListSection(items: items.filter { $0.isInProduction },
                                                 title: "In Production")
                            case .favorites:
                                WatchListSection(items: items.filter { $0.isFavorite },
                                                 title: "Favorites")
                            case .watched:
                                WatchListSection(items: items.filter { $0.isWatched },
                                                 title: "Watched")
                            case .unwatched:
                                WatchListSection(items: items.filter { !$0.isWatched },
                                                 title: "To Watch")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
//                    Picker(selection: $selectedOrder, content: {
//                        ForEach(DefaultListTypes.allCases) { sort in
//                            Text(sort.title).tag(sort)
//                        }
//                    }, label: {
//                        Label("Sort List", systemImage: "arrow.up.arrow.down.circle")
//                    })
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
