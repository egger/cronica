//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI
import TelemetryClient

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
    @State var selectedValue = 0
    @State private var selection = Set<Int>()
    
    
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
        VStack {
            if items.isEmpty {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(selection: $selection) {
                    if !filteredMovieItems.isEmpty {
                        ForEach(filteredMovieItems) { item in
                            NavigationLink(destination:
                                            ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
                            ) {
                                ItemView(title: item.itemTitle, url: item.image, type: item.itemMedia, inSearch: false)
                            }
                        }
                    } else {
                        switch selectedValue {
                        case 1:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie }, title: "Movies")
                            WatchListSection(items: items.filter { $0.itemMedia == .tvShow }, title: "TV Shows")
                        default:
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon},
                                                 title: "Coming Soon")
                            WatchListSection(items: items.filter { $0.itemSchedule == .released },
                                                 title: "Released")
                        }
                    }
                }
            }
        }
        .navigationTitle("Watchlist")
        .refreshable {
            Task {
                await refresh()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker(selection: $selectedValue, label: Text("Sort")) {
                        Text("Default").tag(0)
                        Text("Media Type").tag(1)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                }
            }
        }
        .searchable(text: $query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search watchlist")
        .disableAutocorrection(true)
    }
    
    private func refresh() async {
        DispatchQueue.global(qos: .background).async {
            let background = BackgroundManager()
            background.handleAppRefreshContent()
        }
        viewContext.refreshAllObjects()
        TelemetryManager.send("watchlistView_didRefresh")
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}
