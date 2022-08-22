//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//
import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    private var filteredItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @State private var query = ""
    @State private var selectedOrder: DefaultListTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var multiSelection = Set<WatchlistItem.ID>()
    @Environment(\.editMode) private var editMode
    var body: some View {
        AdaptableNavigationView {
            VStack {
                if items.isEmpty {
                    if scope != .noScope {
                        Text("Your list is empty.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        Text("Your list is empty.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    List(selection: $multiSelection) {
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
                            
                        } else if !query.isEmpty && filteredItems.isEmpty {
                            Text("No results")
                        } else {
                            switch selectedOrder {
                            case .released:
                                WatchListSection(items: items.filter { $0.isReleased },
                                                 title: "Released")
                            case .upcoming:
                                WatchListSection(items: items.filter { $0.isUpcoming },
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
                                WatchListSection(items: items.filter { !$0.isWatched && $0.isReleased },
                                                 title: "To Watch")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .dropDestination(for: ItemContent.self) { items, _  in
                        let context = PersistenceController.shared
                        for item in items {
                            context.save(item)
                        }
                        return true
                    } isTargeted: { inDropArea in
                        print(inDropArea)
                    }
                    .contextMenu(forSelectionType: WatchlistItem.ID.self) { items in
                        if items.count >= 1 {
                            updateWatchButton
                            Divider()
                            deleteAllButton
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if editMode?.wrappedValue.isEditing == true {
                            deleteAllButton
                                .labelStyle(.titleOnly)
                        }
                        EditButton()
                    }
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
                }
            }
            .searchable(text: $query,
                        placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always),
                        prompt: "Search watchlist")
            .searchScopes($scope) {
                ForEach(WatchlistSearchScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .disableAutocorrection(true)
        }
    }
    private var deleteAllButton: some View {
        Button(role: .destructive, action: {
            withAnimation {
                PersistenceController.shared.delete(items: multiSelection)
            }
        }, label: {
            Label("Remove Selected", systemImage: "trash")
        })
    }
    private var updateWatchButton: some View {
        Button(action: {
            PersistenceController.shared.updateMarkAs(items: multiSelection)
        }, label: {
            if selectedOrder != .watched {
                Label("Mark selected as watched", systemImage: "checkmark.circle")
            } else {
                Label("Mark selected as unwatched", systemImage: "minus.circle")
            }
        })
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
