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
    @State private var queryString = ""
    @State private var multiSelection = Set<Int>()
    enum SelectionType: String, CaseIterable, Identifiable {
        case date
        case status
        var id: String { self.rawValue }
    }
    @State private var selected = SelectionType.status
    private var filteredMovieItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(queryString))! as Bool }
    }
    var body: some View {
        NavigationView {
            if items.isEmpty {
                VStack {
                    Image(systemName: "square.stack.fill")
                        .padding()
                    Text("Your list is empty.")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                List {
                    if !filteredMovieItems.isEmpty {
                        ForEach(filteredMovieItems) { item in
                            NavigationLink(destination:
                                            EmptyView()
                            ) {
                                ItemView(title: item.itemTitle, url: item.image, type: item.media)
                            }
                        }
                    } else {
                        WatchlistSectionView(items: items.filter { $0.status == "In Production" || $0.status == "Post Production" || $0.status == "Planned" },
                                             title: "Coming Soon")
                        WatchlistSectionView(items: items.filter { $0.status == "Returning Series"},
                                             title: "Releasing")
                        WatchlistSectionView(items: items.filter { $0.status == "Released" || $0.status == "Ended"},
                                             title: "Released")
                    }
                }
                .navigationTitle("Watchlist")
#if os(iOS)
                .navigationViewStyle(.stack)
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
#endif
                .searchable(text: $queryString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search watchlist")
            }
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}
