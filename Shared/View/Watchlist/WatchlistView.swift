//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: String? = "Watchlist"
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var query = ""
    private var filteredMovieItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationView {
                detailsView
            }
            .navigationViewStyle(.stack)
        } else {
           detailsView
        }
#else
        detailsView
#endif
    }
    
    @ViewBuilder
    var detailsView: some View {
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
                    WatchlistSection(items: items.filter { $0.status == "In Production"
                        || $0.status == "Post Production"
                        || $0.status == "Planned" },
                                         title: "Coming Soon")
                    WatchlistSection(items: items.filter { $0.status == "Returning Series"},
                                         title: "Now Available")
                    WatchlistSection(items: items.filter { $0.status == "Released" || $0.status == "Ended" || $0.status == "Canceled"},
                                         title: "Released")
                }
            }
            .navigationTitle("Watchlist")
            .refreshable { viewContext.refreshAllObjects() }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search watchlist")
            .disableAutocorrection(true)
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, WatchlistController.preview.container.viewContext)
    }
}

private struct WatchlistSection: View {
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
        }
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
