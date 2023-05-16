//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct WatchListSection: View {
    let items: [WatchlistItem]
    var title: String
    private let context = PersistenceController.shared
    @State private var multiSelection = Set<String>()
    @State private var sortOrder = [KeyPathComparator(\WatchlistItem.itemTitle)]
    @State var showDefaultFooter = true
    var alternativeFooter: String?
    var body: some View {
        if !items.isEmpty {
#if os(macOS)
            table
#else
            list
#endif
        } else {
            empty
        }
    }
    
    private var table: some View {
        Table(items, sortOrder: $sortOrder) {
            TableColumn("Title") { item in
                WatchlistItemRow(content: item)
                    .draggable(item)
                    .buttonStyle(.plain)
            }
            TableColumn("Media", value: \.itemMedia.title)
            TableColumn("Genre", value: \.itemGenre)
        }
        .tableStyle(.inset)
    }
    
    private var list: some View {
        List {
            Section {
                ForEach(items) {
                    WatchlistItemRow(content: $0)
                        .draggable($0)
                }
                .onDelete(perform: delete)
            } header: {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                    Spacer()
                    let formatString = NSLocalizedString("items count", comment: "")
                    let result = String(format: formatString, items.count)
                    Text(result)
                }
            } footer: {
                if let alternativeFooter {
                    Text(alternativeFooter)
                }
            }
        }
        .toolbar {
#if os(iOS)
            EditButton()
#endif
        }
    }
    
    private var empty: some View {
        Text("This list is empty.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
    }
    
    private func fetchDroppedItems(_ items: [ItemContent]) {
        for item in items {
            Task {
                let result = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                if let result {
                    PersistenceController.shared.save(result)
                }
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}
#endif
