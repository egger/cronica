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
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .and,
                                       subpredicates: [
                                        NSPredicate(format: "schedule == %d", ContentSchedule.soon.scheduleNumber),
                                        NSPredicate(format: "notify == %d", true),
                                        NSPredicate(format: "contentType == %d", MediaType.movie.watchlistInt)
                                       ])
    )
    var items: FetchedResults<WatchlistItem>
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    var body: some View {
        VStack {
            if !items.isEmpty {
                TitleView(title: "Upcoming Movies",
                          subtitle: "From Watchlist",
                          image: "rectangle.stack")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                                CardView(title: item.itemTitle, url: item.image, subtitle: item.formattedDate)
                                    .contextMenu {
                                        Button(action: {
                                            shareItems = [item.itemLink]
                                            withAnimation {
                                                isSharePresented.toggle()
                                            }
                                        }, label: {
                                            Label("Share",
                                                  systemImage: "square.and.arrow.up")
                                        })
                                        Divider()
                                        Button(role: .destructive, action: {
                                            remove(item: item)
                                        }, label: {
                                            Label("Remove from watchlist", systemImage: "trash")
                                        })
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .sheet(isPresented: $isSharePresented,
                                           content: { ActivityViewController(itemsToShare: $shareItems) })
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
    
    private func remove(item: WatchlistItem) {
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}

struct WatchlistSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoonListView()
    }
}
