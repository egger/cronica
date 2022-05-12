//
//  UpcomingSeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI

struct UpcomingSeasonListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSPredicate(format: "upcomingSeason == %d", true)
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            if !items.isEmpty {
                TitleView(title: "Upcoming Seasons",
                          subtitle: "From Watchlist",
                          image: "rectangle.stack")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                                CardView(title: item.itemTitle, url: item.image, subtitle: "Season \(item.nextSeasonNumber)")
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

struct UpcomingSeasonListView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingSeasonListView()
    }
}
