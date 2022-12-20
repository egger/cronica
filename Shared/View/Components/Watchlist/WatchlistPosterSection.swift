//
//  WatchlistPosterSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct WatchlistPosterSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160 ))],
                          spacing: 20) {
                    ForEach(items, id: \.notificationID) { item in
                        WatchlistItemPoster(content: item)
                            .buttonStyle(.plain)
                    }
                    .onDelete(perform: delete)
                }.padding()
            }
        } else {
            CenterHorizontalView {
                Text("This list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}

struct WatchlistPosterSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistPosterSection(items: [.example])
    }
}
