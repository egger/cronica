//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI

struct WatchListSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    private let context = DataController.shared
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                        ItemView(title: item.itemTitle, url: item.image, type: item.itemMedia, inSearch: false, watched: item.watched, favorite: item.favorite)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            context.updateMarkAs(Id: item.itemId, watched: !item.watched, favorite: nil)
                        }, label: {
                            Label(item.watched ? "Remove from Watched" : "Mark as Watched",
                                  systemImage: item.watched ? "minus.circle" : "checkmark.circle")
                        })
                        .tint(item.watched ? .yellow : .green )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            withAnimation {
                                viewContext.delete(item)
                                try? viewContext.save()
                            }
                        }, label: {
                            Label("Remove", systemImage: "trash")
                        })
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
            try? viewContext.save()
        }
    }
    
}

struct WatchListSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchListSection(items: [WatchlistItem.example], title: "Examples")
    }
}
