//
//  WatchlistSectionView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct ComingSoonListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: false),
        ],
        predicate: NSCompoundPredicate(type: .and,
                                       subpredicates: [
                                        NSPredicate(format: "schedule == %@", "0"),
                                        NSPredicate(format: "notify == %d", true),
                                        NSPredicate(format: "contentType == %d", MediaType.movie.watchlistInt)
                                       ])
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            if !items.isEmpty {
                TitleView(title: "Upcoming Movies",
                          subtitle: "Movies from your Watchlist",
                          image: "rectangle.stack")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                                CardView(title: item.itemTitle, url: item.image, subtitle: item.formattedDate)
                                    .padding([.leading, .trailing], 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

struct WatchlistSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoonListView()
    }
}
