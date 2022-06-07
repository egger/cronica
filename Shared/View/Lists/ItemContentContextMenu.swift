//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

struct ItemContentContextMenu: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = DataController.shared
    func body(content: Content) -> some View {
        return content
            .contextMenu {
                ShareLink(item: item.itemURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(action: {
                    updateWatchlist(item: item)
                }, label: {
                    Label("Add to watchlist", systemImage: "plus.circle")
                })
            }
    }
    
    private func updateWatchlist(item: ItemContent) {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id, type: item.itemContentMedia) {
            Task {
                let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.media)
                if let content {
                    withAnimation {
                        context.saveItem(content: content, notify: content.itemCanNotify)
                        showConfirmation.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            showConfirmation = false
                        }
                    }
                }
            }
        }
    }
}
