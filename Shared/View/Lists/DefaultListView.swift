//
//  DefaultListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//

import SwiftUI

struct DefaultListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    let list: DefaultListTypes
    var body: some View {
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
                        switch list {
                        case .released:
                            WatchListSection(items: items.filter { $0.isReleasedMovie || $0.isReleasedTvShow  },
                                             title: list.title)
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
                                             title: "Unwatched")
                        }
                    }
                }
            }
        }
        .navigationTitle(list.title)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .toolbar {
            EditButton()
        }
        .navigationDestination(for: WatchlistItem.self) { item in
            ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
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

struct DefaultListView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListView(list: .released)
    }
}
