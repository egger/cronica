//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//
import SwiftUI

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
    var body: some View {
        AdaptableNavigationView {
            ScrollView {
                ForEach(DefaultListsOrder.allCases) { list in
                    NavigationLink(destination: NewListView(type: list), label: {
                        HStack {
                            Text(list.title)
                        }
                        .backgroundStyle(.secondary)
                        .padding()
                        .cornerRadius(12)
                    })
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Label("New List", systemImage: "plus.circle")
                        })
                        EditButton()
                    }
                }

            }
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


private struct NewListView: View {
    @StateObject private var viewModel = TableListViewModel()
    @State private var sortOrder = [KeyPathComparator(\WatchlistItem.itemTitle)]
    @State private var query = ""
    let type: DefaultListsOrder
    var body: some View {
        VStack {
            if viewModel.items.isEmpty {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                if UIDevice.isIPad {
                    Table(viewModel.items, sortOrder: $sortOrder) {
                        TableColumn("Titles", value: \.itemTitle) { item in
                            NavigationLink(value: item) {
                                ItemView(content: item)
                            }
                        }
                        TableColumn("Watched", value: \.itemTitle) { watched in
                            if watched.isWatched {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }
                    }
                    .onChange(of: sortOrder) { change in
                        print(change as Any)
                    }
                } else {
                    List {
                        Section {
                            ForEach(viewModel.items) { item in
                                NavigationLink(value: item) {
                                    ItemView(content: item)
                                }
                            }
                        } header: {
                            Text("\(viewModel.items.count) titles")
                        }
                    }
                    
                    
                }
            }
        }
        .navigationTitle(type.title)
        .searchable(text: $query,
                    placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always),
                    prompt: "Search watchlist")
        .toolbar {
            EditButton()
        }
        .autocorrectionDisabled(true)
        .onAppear {
            viewModel.fetch(filter: type)
        }
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
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            //offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}

private struct ListItemView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("")
            }
        }
    }
}
