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
        NavigationStack {
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
                                NavigationLink(value: item) {
                                    ItemView(content: item)
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
                            default:
                                WatchListSection(items: items.filter { $0.itemMedia == .movie && $0.itemSchedule == .released && $0.notify == false && $0.watched == false }, title: "Released Movies")
                                WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .tvShow && !$0.upcomingSeason && $0.notify || $0.itemSchedule == .released && $0.itemMedia == .tvShow && !$0.watched || $0.itemSchedule == .cancelled && !$0.watched }, title: "Released Shows")
                                WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.itemMedia == .movie && $0.notify == true },
                                                 title: "Upcoming Movies")
                                WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.upcomingSeason == true && $0.notify == true },
                                                 title: "Upcoming Seasons")
                                WatchListSection(items: items.filter { $0.itemSchedule == .soon && $0.watched == false && $0.notify == false || $0.itemSchedule == .production },
                                                 title: "In Production")
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: WatchlistItem.self) { item in
                ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                CastDetailsView(title: person.name, id: person.id)
            }
            .refreshable {
                Task {
                    await refresh()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker(selection: $selectedValue, label: Label("Sort", systemImage: "arrow.up.arrow.down.circle")) {
                        Text("Default").tag(0)
                        Text("Media Type").tag(1)
                        Text("Status").tag(2)
                        Text("Favorites").tag(3)
                    }
                    .pickerStyle(.menu)
                    .labelStyle(.iconOnly)
                }
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search watchlist")
            .disableAutocorrection(true)
        }
    }
    
    private func refresh() async {
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
