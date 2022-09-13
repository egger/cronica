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
    var list: DefaultListTypes? = nil
    var title: String? = nil
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    WatchlistItemView(content: item)
                        .draggable(item)
                        .hoverEffect(.highlight)
                }
                .onDelete(perform: delete)
            } header: {
                if let list {
                    Text(NSLocalizedString(list.title, comment: ""))
                }
                if let title {
                    Text(NSLocalizedString(title, comment: ""))
                }
            } footer: {
                Text("\(items.count) items.")
            }
            .dropDestination(for: ItemContent.self) { items, _  in
                for item in items {
                    context.save(item)
                }
                return true
            } isTargeted: { inDropArea in
                print(inDropArea)
            }
        } else {
            Text("This list is empty.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}
