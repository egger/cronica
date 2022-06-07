//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

struct ItemContentContext: ViewModifier {
    @Binding var shareItems: [Any]
    let item: ItemContent
    @Binding var isSharePresented: Bool
    @Binding var showConfirmation: Bool
    private let context = DataController.shared
    func body(content: Content) -> some View {
        return content
            .contextMenu {
                Button(action: {
                    shareItems = [item.itemURL]
                    isSharePresented.toggle()
                }, label: {
                    Label("Share",
                          systemImage: "square.and.arrow.up")
                })
                Button(action: {
                    Task {
                        await updateWatchlist(item: item)
                    }
                }, label: {
                    Label("Add to watchlist", systemImage: "plus.circle")
                })
            }
    }
    
    private func updateWatchlist(item: ItemContent) async {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id, type: item.itemContentMedia) {
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
