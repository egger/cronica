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
    let title: String
    let id: Int
    let image: URL
    let status: String
    let notify: Bool
    let type: String
    var body: some View {
        Button {
#if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: 1.0)
#endif
            if !inWatchlist {
                withAnimation(.easeInOut) {
                    inWatchlist.toggle()
                }
                addItem(title: title, id: id, image: image, status: status, type: type)
                
            } else {
                withAnimation(.easeInOut) {
                    inWatchlist.toggle()
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
                if item.id == id {
                    inWatchlist.toggle()
                }
            }
        }
    }
    
    private func addItem(title: String, id: Int, image: URL, status: String, notify: Bool = false, type: String) {
        withAnimation {
            var inWatchlist: Bool = false
            for i in watchlistItems {
                if i.id == id {
                    inWatchlist = true
                }
            }
            if !inWatchlist {
                let item = WatchlistItem(context: viewContext)
                item.title = title
                item.id = Int32(id)
                item.image = image
                item.status = status
                item.type = type
                item.notify = notify
                do {
                    try viewContext.save()
                } catch {
                    fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
                }
            }

        }
    }
}
