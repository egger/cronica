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
    var body: some View {
        NavigationView {
            if items.isEmpty {
                VStack {
                    Image(systemName: "theatermasks.fill")
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
                            HStack {
                                AsyncImage(url: item.image) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                } placeholder: {
                                    ProgressView()
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(item.title!)
                                            .lineLimit(1)
                                    }
                                    HStack {
                                        Text("Movie")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("Watchlist")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                
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
