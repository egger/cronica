//
//  UpcomingWatchlistContextMenu.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/06/22.
//

import SwiftUI

struct UpcomingWatchlistContextMenu: ViewModifier {
    @Environment(\.managedObjectContext) private var viewContext
    var item: WatchlistItem
    func body(content: Content) -> some View  {
        content
            .contextMenu {
                ShareLink(item: item.itemLink)
                Divider()
                Button(role: .destructive, action: {
                    remove(item: item)
                }, label: {
                    Label("Remove from watchlist", systemImage: "trash")
                })
            }
    }
    
    private func remove(item: WatchlistItem) {
        HapticManager.shared.mediumHaptic()
        withAnimation(.easeInOut) {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}
