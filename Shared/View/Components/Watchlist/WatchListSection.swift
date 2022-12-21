//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI

struct WatchListSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    var title: String
    var body: some View {
        if !items.isEmpty {
#if os(macOS)
            Table(items) {
                TableColumn("Title") { item in
                    WatchlistItemRow(content: item)
                        .buttonStyle(.plain)
                }
                TableColumn("Media", value: \.itemMedia.title)
                TableColumn("Genre", value: \.itemGenre)
            }
#else
            Section {
                ForEach(items, id: \.notificationID) { item in
                    WatchlistItemRow(content: item)
                        .draggable(item)
                }
                .onDelete(perform: delete)
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            } footer: {
                Text("\(items.count) items")
                    .padding(.bottom)
            }
            .dropDestination(for: ItemContent.self) { items, _  in
                for item in items {
                    context.save(item)
                }
                return true
            }
#endif
        } else {
            Text("This list is empty.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}
