//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI
import TelemetryClient

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
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
    
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationView {
                details
            }
            .navigationViewStyle(.stack)
        } else {
            details
        }
#else
        details
#endif
    }
    
    var details: some View {
        VStack {
            if items.isEmpty {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    if !filteredMovieItems.isEmpty {
                        ForEach(filteredMovieItems) { item in
                            NavigationLink(destination:
                                            ContentDetailsView(title: item.itemTitle,
                                                               id: item.itemId,
                                                               type: item.itemMedia)
                            ) {
                                ItemView(title: item.itemTitle,
                                         url: item.image,
                                         type: item.itemMedia)
                            }
                        }
                    } else {
                        switch selectedValue {
                        case 1:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie },
                                             title: "Movies")
                            WatchListSection(items: items.filter { $0.itemMedia == .tvShow },
                                             title: "TV Shows")
                        case 2:
                            WatchListSection(items: items.filter { $0.watched == false },
                                             title: "To Watch")
                            WatchListSection(items: items.filter { $0.watched == true },
                                             title: "Watched")
                        case 3:
                            WatchListSection(items: items.filter { $0.favorite == true },
                                             title: "Favorites")
                        case 4:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie && $0.itemSchedule == .released && $0.notify == false && $0.watched == false }, title: "Released Movies")
                        case 5:
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .tvShow && $0.upcomingSeason == false && $0.notify == true || $0.itemSchedule == .released && $0.itemMedia == .tvShow && $0.watched == false }, title: "Released Shows")
                        case 6:
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .movie && $0.notify == true },
                                             title: "Upcoming Movies")
                        case 7:
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.upcomingSeason == true && $0.notify == true },
                                             title: "Upcoming Seasons")
                        case 8:
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.watched == false && $0.notify == false },
                                             title: "In Production")
                        default:
                            WatchListSection(items: items.filter { $0.itemMedia == .movie && $0.itemSchedule == .released && $0.notify == false && $0.watched == false }, title: "Released Movies")
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .tvShow && $0.upcomingSeason == false && $0.notify == true || $0.itemSchedule == .released && $0.itemMedia == .tvShow && $0.watched == false }, title: "Released Shows")
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .movie && $0.notify == true },
                                             title: "Upcoming Movies")
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.upcomingSeason == true && $0.notify == true },
                                             title: "Upcoming Seasons")
                            WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.watched == false && $0.notify == false },
                                             title: "In Production")
                        }
                    }
                }
            }
        }
        .navigationTitle("Watchlist")
        .navigationBarTitleDisplayMode(.large)
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
                        Text("Status").tag(2)
                        Text("Favorites").tag(3)
                        Menu("Releases") {
                            Picker(selection: $selectedValue, label: Text("Sort")) {
                                Text("Released Movies").tag(4)
                                Text("Released Shows").tag(5)
                                Text("Upcoming Movies").tag(6)
                                Text("Upcoming Seasons").tag(7)
                                Text("In Production").tag(8)
                            }
                        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewContext.refreshAllObjects()
        }
        TelemetryManager.send("WatchlistView_refresh")
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext,
                                     DataController.preview.container.viewContext)
    }
}
