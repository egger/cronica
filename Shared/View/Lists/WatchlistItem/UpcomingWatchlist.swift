//
//  UpcomingWatchlist.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 03/11/22.
//

import SwiftUI

struct UpcomingWatchlist: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .or, subpredicates: [
            NSCompoundPredicate(type: .and,
                                subpredicates: [
                                    NSPredicate(format: "schedule == %d", ItemSchedule.soon.toInt),
                                    NSPredicate(format: "notify == %d", true),
                                    NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                ])
            ,
            NSPredicate(format: "upcomingSeason == %d", true)])
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        UpcomingListView(items: items.filter { $0.image != nil })
    }
}

struct UpcomingWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingWatchlist()
    }
}



struct CustomListPinned: View {
    @FetchRequest(
        entity: CustomList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        predicate: NSPredicate(format: "isPin == %d", true)
    ) private var lists: FetchedResults<CustomList>
    var body: some View {
        if !lists.isEmpty {
            ForEach(lists) { list in
                HorizontalWatchlistList(items: list.itemsArray,
                                        title: list.itemTitle,
                                        subtitle: "pinnedList")
            }
        }
    }
}
