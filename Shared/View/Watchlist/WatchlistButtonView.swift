//
//  WatchlistButtonView.swift
//  Story
//
//  Created by Alexandre Madeira on 11/02/22.
//

import SwiftUI

struct WatchlistButtonView: View {
    @State private var inWatchlist: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var watchlistItems: FetchedResults<WatchlistItem>
    let content: Content
    let notify: Bool
    let type: Int
    var body: some View {
        Button {
#if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: 1.0)
#endif
            if !inWatchlist {
                withAnimation {
                    inWatchlist.toggle()
                    addItem()
                }
            } else {
                withAnimation {
                    inWatchlist.toggle()
                    delete()
                }
            }
            
        } label: {
            withAnimation(.easeInOut) {
                Label(!inWatchlist ? "Add to watchlist" : "Remove from watchlist", systemImage: !inWatchlist ? "plus.square" : "minus.square")
            }
        }
        .buttonStyle(.bordered)
        .tint(inWatchlist ? .red : .blue)
        .controlSize(.large)
        .onAppear {
            for item in watchlistItems {
                if item.id == content.id {
                    inWatchlist.toggle()
                }
            }
        }
    }
    
    private func addItem() {
        var inWatchlist: Bool = false
        for item in watchlistItems {
            if item.id == content.id {
                inWatchlist = true
            }
        }
        if !inWatchlist {
            let context = DataController()
            context.saveItem(content: content, type: self.type, notify: false)
        }
    }
    private func delete() {
        for item in watchlistItems {
            if item.id == content.id {
                let context = DataController()
                do {
                    try context.removeItem(id: item)
                } catch {
                    fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
                }
            }
        }
    }
}
