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
            if !watchlistItems.isEmpty {
                VStack {
                    HStack {
                        Text("Coming Soon")
                            .font(.headline)
                            .padding([.top, .horizontal])
                        Spacer()
                    }
                    HStack {
                        Text("From Watchlist")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(watchlistItems.filter { $0.status == "Post Production"}) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.media)) {
                                CardView(title: item.itemTitle, url: item.image)
                                    .padding([.leading, .trailing], 4)
                            }
                            .padding(.leading, item.id == self.watchlistItems.first!.id ? 20 : 0)
                            .padding(.trailing, item.id == self.watchlistItems.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            } else {
                EmptyView()
            }
            
        }
    }
}

struct HomeListItemsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemsView()
    }
}
