//
//  HomeListItemsView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import SwiftUI

struct HomeListItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var watchlistItems: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            HStack {
                Text("Up Next")
                    .font(.headline)
                    .padding([.top, .horizontal])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(watchlistItems.filter { $0.status == "In Production"
                        || $0.status == "Post Production" || $0.status == "Planned" }) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.media)) {
                                CardView(title: item.itemTitle, url: item.image!)
                                    .padding([.leading, .trailing], 4)
                            }
                            .padding(.leading, item.id == self.watchlistItems.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.watchlistItems.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                }
            }
        }
    }
}

struct HomeListItemsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemsView()
    }
}
