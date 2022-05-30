//
//  WatchListSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/22.
//

import SwiftUI

struct WatchListSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    private let context = DataController.shared
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                        ItemView(content: item)
                            .contextMenu {
                                Button(action: {
                                    withAnimation {
                                        context.updateMarkAs(Id: item.itemId, watched: !item.watched, favorite: nil)
                                    }
                                }, label: {
                                    Label(item.watched ? "Remove from Watched" : "Mark as Watched",
                                          systemImage: item.watched ? "minus.circle" : "checkmark.circle")
                                })
                                Button(action: {
                                    shareItems = [item.itemLink]
                                    withAnimation {
                                        isSharePresented.toggle()
                                    }
                                }, label: {
                                    Label("Share",
                                          systemImage: "square.and.arrow.up")
                                })
                                Divider()
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        viewContext.delete(item)
                                        try? viewContext.save()
                                    }
                                }, label: {
                                    Label("Remove", systemImage: "trash")
                                })
                            }
                            .sheet(isPresented: $isSharePresented,
                                   content: { ActivityViewController(itemsToShare: $shareItems) })
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            HapticManager.shared.lightHaptic()
                            withAnimation {
                                context.updateMarkAs(Id: item.itemId, watched: !item.watched, favorite: nil)
                            }
                        }, label: {
                            Label(item.watched ? "Remove from Watched" : "Mark as Watched",
                                  systemImage: item.watched ? "minus.circle" : "checkmark.circle")
                        })
                        .labelStyle(.titleAndIcon)
                        .tint(item.watched ? .yellow : .green )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            HapticManager.shared.mediumHaptic()
                            viewContext.delete(item)
                            try? viewContext.save()
                        }, label: {
                            Label("Remove", systemImage: "trash")
                        })
                        .labelStyle(.titleAndIcon)
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
}

struct WatchListSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchListSection(items: [WatchlistItem.example], title: "Examples")
    }
}
