//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI

struct WatchListSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    private let context = PersistenceController.shared 
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        ItemView(content: item)
                            .contextMenu {
                                Button(action: {
                                    withAnimation {
                                        context.updateMarkAs(id: item.itemId, watched: !item.watched, favorite: nil)
                                    }
                                }, label: {
                                    Label(item.watched ? "Remove from Watched" : "Mark as Watched",
                                          systemImage: item.watched ? "minus.circle" : "checkmark.circle")
                                })
                                ShareLink(item: item.itemLink)
                                Divider()
                                Button(role: .destructive, action: {
                                    deleteItem(item: item)
                                }, label: {
                                    Label("Remove", systemImage: "trash")
                                })
                            }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            HapticManager.shared.lightHaptic()
                            withAnimation {
                                context.updateMarkAs(id: item.itemId, watched: !item.watched, favorite: nil)
                            }
                        }, label: {
                            Label(item.watched ? "Remove from Watched" : "Mark as Watched",
                                  systemImage: item.watched ? "minus.circle" : "checkmark.circle")
                            .labelStyle(.titleAndIcon)
                        })
                        .controlSize(.large)
                        .tint(item.watched ? .yellow : .green )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            deleteItem(item: item)
                        }, label: {
                            Label("Remove", systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                        })
                        .controlSize(.large)
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
        }
    }
    
    private func deleteItem(item: WatchlistItem) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            context.delete(item)
        }
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
    
}

struct WatchListSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchListSection(items: [WatchlistItem.example], title: "Examples")
    }
}
