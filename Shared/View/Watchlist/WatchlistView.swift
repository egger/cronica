//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: String? = "Watchlist"
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    @State private var multiSelection = Set<Int>()
    enum SelectionType: String, CaseIterable, Identifiable {
        case release
        case date
        var id: String { self.rawValue }
    }
    @State private var selected: SelectionType = .release
    private var filteredMovieItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    var body: some View {
        NavigationView {
            if items.isEmpty {
                VStack {
                    Text("Your list is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                List {
                    if !filteredMovieItems.isEmpty {
                        ForEach(filteredMovieItems) { item in
                            NavigationLink(destination:
                                            DetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
                            ) {
                                ItemView(title: item.itemTitle, url: item.image, type: item.itemMedia, inSearch: false)
                            }
                        }
                    } else {
                        switch selected {
                        case .release:
                            WatchlistSectionView(items: items.filter { $0.status == "In Production"
                                || $0.status == "Post Production"
                                || $0.status == "Planned" },
                                                 title: "Coming Soon")
                            WatchlistSectionView(items: items.filter { $0.status == "Returning Series"},
                                                 title: "Releasing")
                            WatchlistSectionView(items: items.filter { $0.status == "Released" || $0.status == "Ended"},
                                                 title: "Released")
                        case .date:
                            Text("Hum")
                        }
                        
                    }
                }
                .navigationTitle("Watchlist")
                .refreshable { viewContext.refreshAllObjects() }
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Picker("Sort Watchlist", selection: $selected) {
                                ForEach(SelectionType.allCases) { selection in
                                    Text(selection.rawValue.capitalized)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                }
                .searchable(text: $query,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Search watchlist")
                .disableAutocorrection(true)
            }
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}

private struct WatchlistSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                        ItemView(title: item.itemTitle, url: item.image, type: item.itemMedia, inSearch: false)
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
        } else { EmptyView() }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
