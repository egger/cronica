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
        sortDescriptors: [NSSortDescriptor(keyPath: \MovieItem.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MovieItem>
    @State private var queryString = ""
    @State private var multiSelection = Set<Int>()
    enum selectionType: String, CaseIterable, Identifiable {
        case title
        case release
        case status
        
        var id: String { self.rawValue }
    }
    @State private var selected = selectionType.status
    var filteredMovieItems: [MovieItem] {
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
                            NavigationLink(destination: MovieDetailsView(movieID: Int(item.id), movieTitle: item.title!)) {
                                ItemView(title: item.title!, image: item.image!, type: "Movie")
                            }
                        }
                    } else {
                        WatchlistSection(movies: items.filter { $0.status == "Released"}, title: "Released")
                        WatchlistSection(movies: items.filter { $0.status == "In Production"}, title: "In Production")
                        WatchlistSection(movies: items.filter { $0.status == "Post Production"}, title: "Post Production")
                        WatchlistSection(movies: items.filter { $0.status == "Planned"}, title: "Planned")
                        WatchlistSection(movies: items.filter { $0.status == "Canceled"}, title: "Canceled")
                        WatchlistSection(movies: items.filter { $0.status == "Rumored"}, title: "Rumored")
                    }
                }
                .refreshable {
                    
                }
                .navigationTitle("Watchlist")
#if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Picker("Sort Watchlist", selection: $selected) {
                                ForEach(selectionType.allCases) { selection in
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
                .searchable(text: $queryString, prompt: "Search in your watchlist.")
            }
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}

struct WatchlistSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    let movies: [MovieItem]
    let title: String
    var body: some View {
        Section {
            ForEach(movies) { item in
                NavigationLink(destination: MovieDetailsView(movieID: Int(item.id), movieTitle: item.title!)) {
                    ItemView(title: item.title!, image: item.image!, type: "Movie")
                        .contextMenu {
                            Button {
                                
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }

                        }
                }
            }
            .onDelete(perform: deleteItems)
        } header: {
            Text(title)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { movies[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
