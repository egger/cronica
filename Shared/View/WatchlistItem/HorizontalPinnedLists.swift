//
//  HorizontalPinnedLists.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/06/23.
//

import SwiftUI

struct HorizontalPinnedList: View {
    @FetchRequest(
        entity: CustomList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        predicate: NSPredicate(format: "isPin == %d", true)
    ) private var lists: FetchedResults<CustomList>
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        if !lists.isEmpty {
            ForEach(lists) { list in
                HorizontalWatchlistList(items: list.itemsArray,
                                        title: list.itemTitle,
                                        subtitle: "pinnedList",
                                        showPopup: $showPopup,
                                        popupType: $popupType)
            }
        }
    }
}
