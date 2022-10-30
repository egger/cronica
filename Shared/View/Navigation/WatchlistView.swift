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
    @State private var filteredItems = [WatchlistItem]()
    @State private var query = ""
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var multiSelection = Set<String>()
    @Environment(\.editMode) private var editMode
    @State private var isSearching = false
    var body: some View {
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
                        
                    } else if !query.isEmpty && filteredItems.isEmpty && !isSearching  {
                        Text("No results")
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
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .dropDestination(for: ItemContent.self) { items, _  in
                    for item in items {
                        Task {
                            let result = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                            if let result {
                                PersistenceController.shared.save(result)
                            }
                        }
                    }
                    return true
                }
                .contextMenu(forSelectionType: String.self) { items in
                    if items.count >= 1 {
                        updateWatchButton
                        updatePinButton
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
                        Menu(content: {
                            updateWatchButton
                            updatePinButton
                            Divider()
                            deleteAllButton
                        }, label: {
                            Label("Options", systemImage: "ellipsis.circle.fill")
                        })
                        .disabled(multiSelection.isEmpty ? true : false)
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
        .onChange(of: selectedOrder) { _ in
            if multiSelection.count > 0 {
                multiSelection.removeAll()
            }
        }
        .task(id: query) {
            do {
                isSearching = true
                try await Task.sleep(nanoseconds: 300_000_000)
                if !filteredItems.isEmpty { filteredItems.removeAll() }
                filteredItems.append(contentsOf: items.filter { ($0.title?.localizedStandardContains(query))! as Bool })
                isSearching = false
            } catch {
                if Task.isCancelled { return }
                TelemetryErrorManager.shared.handleErrorMessage(error.localizedDescription,
                                                                for: "WatchlistView.task(id: query)")
            }
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
    
    private var updatePinButton: some View {
        Button(action: {
            PersistenceController.shared.updatePin(items: multiSelection)
        }, label: {
            Label("Pin Items", systemImage: "pin.fill")
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
