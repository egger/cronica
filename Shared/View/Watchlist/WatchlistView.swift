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
    @State private var searchText = ""
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
                    ForEach(items) { item in
                        NavigationLink(destination: MovieDetailsView(movieID: Int(item.id), movieTitle: item.title!)) {
                            ItemView(title: item.title!, image: item.image!, type: "Movie")
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .refreshable {
                    
                }
                .navigationTitle("Watchlist")
                #if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                #endif
                .searchable(text: $searchText, prompt: "Search in your watchlist.")
                
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}
