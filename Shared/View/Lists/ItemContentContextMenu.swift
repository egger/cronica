//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

@preconcurrency import SwiftUI

struct ItemContentContextMenu: ViewModifier, Sendable {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = PersistenceController.shared
    func body(content: Content) -> some View {
        return content
            .contextMenu {
                ShareLink(item: item.itemURL)
                Button(action: {
                    updateWatchlist(with: item)
                }, label: {
                    Label("Add to watchlist", systemImage: "plus.circle")
                })
            }
    }
    
    private func updateWatchlist(with item: ItemContent) {
        HapticManager.shared.softHaptic()
        if !context.isItemSaved(id: item.id, type: item.itemContentMedia) {
            Task {
                let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.itemContentMedia)
                if let content {
                    withAnimation {
                        self.context.save(content)
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
