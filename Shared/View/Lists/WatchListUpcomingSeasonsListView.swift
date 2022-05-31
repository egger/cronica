//
//  UpcomingSeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/05/22.
//

import SwiftUI

struct WatchListUpcomingSeasonsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true),
        ],
        predicate: NSPredicate(format: "upcomingSeason == %d", true)
    )
    var items: FetchedResults<WatchlistItem>
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
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
                                    .contextMenu {
                                        Button(action: {
                                            HapticManager.shared.lightHaptic()
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
        HapticManager.shared.mediumHaptic()
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}

struct UpcomingSeasonListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListUpcomingSeasonsListView()
    }
}
