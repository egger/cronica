//
//  WatchlistSectionView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import SwiftUI

struct WatchlistSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Section {
                ForEach(items) { item in
                    if item.media == MediaType.movie {
                        NavigationLink(destination: MovieDetails(title: item.itemTitle, id: item.itemId)) {
                            ItemView(title: item.itemTitle, url: item.image, type: item.media)
                        }
                    } else {
                        NavigationLink(destination: TVDetailsView(title: item.itemTitle, id: item.itemId)) {
                            ItemView(title: item.itemTitle, url: item.image, type: item.media)
                        }
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text(title)
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

struct WatchlistSectionView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistSectionView(items: [WatchlistItem.example], title: "")
    }
}
