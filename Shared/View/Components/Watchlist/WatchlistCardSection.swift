//
//  WatchlistCardSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct WatchlistCardSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))],
                          spacing: 20) {
                    ForEach(items, id: \.notificationID) { item in
                        WatchlistItemFrame(content: item)
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

struct WatchlistCardSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistCardSection(items: [.example])
    }
}
