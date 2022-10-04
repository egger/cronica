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
            Section {
                ForEach(items, id: \.notificationID) { item in
                    WatchlistItemView(content: item)
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
