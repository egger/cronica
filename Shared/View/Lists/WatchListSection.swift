//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI

struct WatchListSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                        ItemView(title: item.itemTitle, url: item.image, type: item.itemMedia, inSearch: false, watched: item.watched)
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
